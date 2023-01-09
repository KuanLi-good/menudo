const mongoose = require('mongoose');  
const ItemSchema = new mongoose.Schema({  
  id: String,
  seller: String,
  name: String,
  price: Number,
  image: String
});
mongoose.model('Item', ItemSchema);
module.exports = mongoose.model('Item');


