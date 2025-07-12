const User = require('../models/user');
const UserCredential = require('../models/userCredential');
const { hashPassword, comparePassword } = require('./bcryptService');
const { generateToken } = require('./jwtService');


exports.signup = async ({ name, email, password }) => {
  console.log("🔍 signup received:", { name, email, password });

  if (!name || !email || !password) {
    throw new Error('Name, email, and password are required');
  }

  const existingCred = await UserCredential.findOne({ email });
  if (existingCred) throw new Error('User already exists');

  const hashedPassword = await hashPassword(password);
  const credentials = await UserCredential.create({
    email,
    password: hashedPassword
  });

  console.log(" Created credentials:", credentials);

  console.log(" Creating user with", { name, userId: credentials._id });

  const user = await User.create({
    name,
    userId: credentials._id
  });

  console.log(" Created user:", user);

  return { message: 'Signup successful', userId: user._id };
};



exports.login = async ({ email, password }) => {
  const credentials = await UserCredential.findOne({ email });
  if (!credentials) throw new Error('Invalid credentials');

  const isMatch = await comparePassword(password, credentials.password);
  if (!isMatch) throw new Error('Invalid credentials');

  const user = await User.findOne({ userId: credentials._id });
  if (!user) throw new Error('User profile not found');

  // const token = generateToken({ userId: user._id });
  
  return user ;
};
