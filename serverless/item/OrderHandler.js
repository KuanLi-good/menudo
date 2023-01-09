"use strict";
const connectToDatabase = require('../db');
const Seller = require('../user/User');
const Order = require('./Order');
const PushNotifications = require('@pusher/push-notifications-server');
    
let pushNotifications = new PushNotifications({
    instanceId: 'a2f5374e-6c0b-43d2-a4ff-2343518d63ec',
    secretKey: '0192BDA72DD2EA6E2682B5B35171AD225405E35C24B74F802E5220CDD9DCCADC'
});

/**
 * Functions
 */


module.exports.sendOrder = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
    sendOrder(JSON.parse(event.body))
    )
    .then(session => ({
      statusCode: 200,
      body: JSON.stringify(session)
    }))
    .catch(err => ({
      statusCode: err.statusCode || 500,
      headers: { 'Content-Type': 'text/plain' },
      body: err.message
    }));
};


module.exports.getOrder = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      getOrder(event.pathParameters.id)
    )
    .then(session => ({
      statusCode: 200,
      body: JSON.stringify(session)
    }))
    .catch(err => ({
      statusCode: err.statusCode || 500,
      headers: { 'Content-Type': 'text/plain' },
      body: { stack: err.stack, message: err.message }
    }));
};

module.exports.getOrdersBySeller = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      getOrdersBySeller(event.requestContext.authorizer.principalId)
    )
    .then(session => ({
      statusCode: 200,
      body: JSON.stringify(session)
    }))
    .catch(err => ({
      statusCode: err.statusCode || 500,
      headers: { 'Content-Type': 'text/plain' },
      body: { stack: err.stack, message: err.message }
    }));
};


module.exports.completeOrder = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      completeOrder(event.pathParameters.id)
    )
    .then(session => ({
      statusCode: 200,
      body: JSON.stringify(session)
    }))
    .catch(err => ({
      statusCode: err.statusCode || 500,
      headers: { 'Content-Type': 'text/plain' },
      body: { stack: err.stack, message: err.message }
    }));
};



/**
 * Helpers
 */


  function sendOrder(eventBody){

    pushNotifications.publishToInterests(['send_order'], {
      apns: {
          aps: {
              alert: {
                  title: "⏳ New Order Arrived",
                  body: `An order for ${eventBody.items.toString()} has been made.`,
              },
              sound: 'default'
          }
      }
  })
  // .then(response => console.log('Just published:', response.publishId))
  .catch(err => Promise.reject(new Error(err)));

    return Seller.findOne({user:eventBody.seller})
    .then(user =>
      !user
        ? Promise.reject('No seller found.')
        : Order.create({ id: eventBody.id, seller: eventBody.seller, items: eventBody.items, total_price: eventBody.total_price, customer: eventBody.customer }))
    .then(order => order)
    .catch(err => Promise.reject(new Error(err)));
        // store the new order
  }

  function getOrdersBySeller(userId) {
    return Seller.findById(userId, { password: 0 })
    .then(user =>
      !user
      ? Promise.reject('No seller found.')
      : Order.find({seller: user.user}))
    .then(orders => 
      !orders.length
          ? Promise.reject('No order found.')
          : orders)
    .then(orders => orders)
    .catch(err => Promise.reject(new Error(err)));
  }
  
  function getOrder(id) {
    return Order.findOne({id: id})
        .then(order =>
          !order
            ? Promise.reject('No order found.')
            : order.items)
        .then(items =>
          !items.length
            ? Promise.reject('No items found.')
            : Order.findOne({id: id}))
        .then(order => order)
        .catch(err => Promise.reject(new Error(err)));
  }

  function completeOrder(id) {
    
    // if (alertMessage !== false) {
    //   pushNotifications.publishToInterests([`complete_${customerId}`], {
    //         apns: { 
    //             aps: {
    //                 alert: {
    //                     title: "Order Complete",
    //                     body: "Your order has been completed. Bon Appetit.",
    //                 }, 
    //                 sound: 'default'
    //             } 
    //         }
    //   })
    // .then(response => console.log('Just published:', response.publishId))
    // .catch(err => Promise.reject(new Error(err)));
    // }
    return Order.findOneAndRemove({id: id})
    .then(order =>
      !order
      ? Promise.reject('No order found.')
      : order)
    .then({"message": "Removed order with id: " + id})
    .catch(err => Promise.reject(new Error(err)));
  }