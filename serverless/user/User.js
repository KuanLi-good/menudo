const mongoose = require('mongoose');  
const SellerSchema = new mongoose.Schema({  
  user: String,
  full_name: String,
  email: String,
  uuid_major: { type: Number, min: 0, max: 999 },
  restaurant_name: String
});
mongoose.model('Seller', SellerSchema);

module.exports = mongoose.model('Seller');