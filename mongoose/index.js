var mongoose = require('mongoose');
var Schema = mongoose.Schema;

var vehicleSchema = new Schema({
  color: String,
  style: String,
  used: Boolean,
  year: Number,
}, { collection: 'cars' });

var Vehicle = mongoose.model('Vehicle', vehicleSchema)
mongoose.set('debug', true);
mongoose.connect('mongodb://localhost/keyhole', { useNewUrlParser: true });

var db = mongoose.connection;
db.on('error', console.error.bind(console, 'connection error:'));
db.once('open', function callback () {
  Vehicle.find(function (err, vehicles) {
    if (err) { console.log(err); }
    console.log('total # of vehicles: ' + vehicles.length);
  });

  Vehicle.find({color: 'Red', style: 'Truck'}, function (err, vehicles) {
    if (err) { console.log(err); }
    console.log('total # of red trucks: ' + vehicles.length);
  });


  Vehicle.find({color: 'Black', style: 'Monster Truck'}, function (err, vehicles) {
    if (err) { console.log(err); }
    console.log('total # of black monster trucks: ' + vehicles.length);
    var blackMonsterTruck = new Vehicle({ color: 'Black', style: 'Monster Truck' });
    blackMonsterTruck.save(function (err, truck) {
      if (err) return console.error(err);
      Vehicle.find({color: 'Black', style: 'Monster Truck'}, function (err, vehicles) {
        if (err) { console.log(err); }
        console.log('total # of black monster trucks: ' + vehicles.length);
        blackMonsterTruck.remove({color: 'Black', style: 'Monster Truck'}, function (err, vehicles) {
          if (err) { console.log(err); }
          db.close();
        });
      });
    });
  });

});
