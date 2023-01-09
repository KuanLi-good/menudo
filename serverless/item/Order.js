const mongoose = require('mongoose');  
const OrderSchema = new mongoose.Schema({  
  id: String,
  seller: String,
  items: [String],
  total_price: Number,
  customer: String
});
mongoose.model('Order', OrderSchema);
module.exports = mongoose.model('Order');