const connectToDatabase = require('../db');
const Seller = require('../user/User');
const jwt = require('jsonwebtoken');

/* 
 * Functions
 */

module.exports.login = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      login(JSON.parse(event.body))
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

module.exports.registerIfNotExist = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
    registerIfNotExist(JSON.parse(event.body))
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

module.exports.editProfile = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      editProfile(event.requestContext.authorizer.principalId, JSON.parse(event.body))
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

module.exports.register = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      register(JSON.parse(event.body))
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

module.exports.me = (event, context) => {
  context.callbackWaitsForEmptyEventLoop = false;
  return connectToDatabase()
    .then(() =>
      me(event.requestContext.authorizer.principalId)
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

function signToken(id) {
  return jwt.sign({ id: id }, process.env.JWT_SECRET, {
    expiresIn: 86400 // expires in 24 hours
  });
}

function checkIfInputIsValid(eventBody) {
  if (!eventBody.user) return Promise.reject(new Error('User ID not provided.'))
  if 
    // 000011.9134c48e58484ad52299cb393541aa78.1781 = 6 + 4 + 2 + 32
    (eventBody.user.length != 44)
   {
    return Promise.reject(new Error('User identifier error. User identifier has to be  44 characters. '));
  }

  if (
    !(eventBody.full_name &&
      // eventBody.name.length > 5 && // Username needs to longer than 5 characters
      typeof eventBody.full_name === 'string')
  ) return Promise.reject(new Error('Username error. '));

  if (
    !(eventBody.email &&
      typeof eventBody.email === 'string')
  ) return Promise.reject(new Error('Email error. Email must have valid characters.'));

  return Promise.resolve();
}

function register(eventBody) {
  return checkIfInputIsValid(eventBody) // validate input
    .then(() =>
      Seller.create({ user: eventBody.user, full_name: eventBody.full_name, email: eventBody.email, uuid_major: eventBody.uuid_major }) 
      // create the new user
    )
    .then(user => ({ auth: true, token: signToken(user._id) })); // sign the token and send it back
}

function login(user) {
  return ({ auth: true, token: signToken(user._id) });
}


function registerIfNotExist(eventBody) {
  return Seller.findOne({ user: eventBody.user })
    .then(user =>
      !user
        ? register(eventBody)
        : login(user)
    )
    // .then(token => ({token: token})); 
    .catch(err => Promise.reject(new Error(err)));
}


function me(userId) {
  return Seller.findById(userId, { password: 0 })
    .then(user =>
      !user
        ? Promise.reject('No user found.')
        : user
    )
    .catch(err => Promise.reject(new Error(err)));
}


function editProfile(userId, eventBody) {
  return Seller.findById(userId, { password: 0 })
    .then(user =>
      !user
        ? Promise.reject('No user found.')
        : Seller.findByIdAndUpdate(user._id, {
          full_name: eventBody.full_name,
          email: eventBody.email,
          restaurant_name: eventBody.restaurant_name }))
    .then(user => user)
    .catch(err => Promise.reject(new Error(err)));
}