"use strict";
const connectToDatabase = require('../db');
const Item = require('./Item');
const Seller = require('../user/User');
/**
 * Functions
 */

module.exports.getInventory = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      getInventory(event.pathParameters.id)
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

module.exports.uploadItem = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      uploadItem(event.requestContext.authorizer.principalId, JSON.parse(event.body))
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

module.exports.editItem = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      editItem(event.requestContext.authorizer.principalId, JSON.parse(event.body))
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

module.exports.deleteItem = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
    deleteItem(event.requestContext.authorizer.principalId, event.pathParameters.id)
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





/**
 * Helpers
 */


 function checkIfInputIsValid(eventBody) {
  // if (!eventBody.seller) return Promise.reject(new Error('Seller ID not provided.'))
  if (!eventBody.name) Promise.reject(new Error('Item name not provided.'))
  return Promise.resolve();
}


 function getInventory(id) {
  // findOne() - if query matches, first document is returned, otherwise null.
  // find() - no matter the number of documents matched, a cursor is returned, never null.
  return Seller.findOne({user: id})
      .then(user =>
        !user
          ? Promise.reject('No user found.')
          : Item.find({seller: user.user}))
      .then(items =>
        !items.length
          ? Promise.reject('No items found.')
          : items)
      .then(items => items)
      .catch(err => Promise.reject(new Error(err)));
  }

  function editItem(userId, eventBody) {
    return checkIfInputIsValid(eventBody)
    .then(() =>
    Seller.findById(userId, { password: 0 }))
    .then(user =>
      !user
      ? Promise.reject('No user found.')
      // upsert: if item with the same name not found, create a new one 
      : Item.findOneAndUpdate({id: eventBody.id}, {
        seller: eventBody.seller,
        name: eventBody.name,
        price: eventBody.price,
        image: eventBody.image }, {upsert: true}))
    .then(item => item)
    .catch(err => Promise.reject(new Error(err)));
  }

  function uploadItem(userId, eventBody){
    return checkIfInputIsValid(eventBody)
    .then(() =>
    Seller.findById(userId, { password: 0 }))
    .then(user =>
      !user
        ? Promise.reject('No user found.')
        : Item.create({ id: eventBody.id, seller: eventBody.seller, name: eventBody.name, price: eventBody.price, image: eventBody.image }))
    .then(item => item)
    .catch(err => Promise.reject(new Error(err)));
        // store the new item
  }

  function deleteItem(userId, id) {
    return Seller.findById(userId, { password: 0 })
    .then(user =>
      !user
      ? Promise.reject('No user found.')
      // upsert: if item with the same name not found, create a new one 
      : Item.findOneAndRemove({id: id}))
    .then({"message": "Removed note with id: " + id})
    .catch(err => Promise.reject(new Error(err)));
  }

