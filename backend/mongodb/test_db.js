const mongoose = require('mongoose');
const Activity = require('./schema/activity'); // Adjust the path if needed

mongoose.connect(
  'mongodb+srv://secret_username:secret_password@cluster0.bxz4o.mongodb.net/tectags?retryWrites=true&w=majority&appName=Cluster0',
  {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  }
);

async function checkCountedAmount() {
  try {
    const activities = await Activity.find({}, { countedAmount: 1 });
    console.log('🔍 Retrieved Activities:', activities);
  } catch (error) {
    console.error('❌ Error fetching activities:', error);
  } finally {
    mongoose.connection.close();
  }
}

checkCountedAmount();

// RESPONSE:
// $ node test_db.js 
// (node:17452) [MONGODB DRIVER] Warning: useNewUrlParser is a deprecated option: useNewUrlParser has no effect since Node.js Driver version 4.0.0 and will be removed in the next major vers
// ion
// (Use `node --trace-warnings ...` to show where the warning was created)
// (node:17452) [MONGODB DRIVER] Warning: useUnifiedTopology is a deprecated option: useUnifiedTopology has no effect since Node.js Driver version 4.0.0 and will be removed in the next majo
// r version
// � Retrieved Activities: [
//   { _id: new ObjectId('67e97d72b6d5c474cb4fdcb3'), countedAmount: 7 },
//   { _id: new ObjectId('67e97dd5b6d5c474cb4fdcc2'), countedAmount: 10 },
//   { _id: new ObjectId('67e97e16b6d5c474cb4fdccb'), countedAmount: 3 }