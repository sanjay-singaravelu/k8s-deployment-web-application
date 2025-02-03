# Use an official Node.js runtime as a parent image
FROM node:16

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if it exists) to the container
COPY src/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files (including src/server.js)
COPY src/ .

# Expose the port your Node.js app will run on
EXPOSE 3008

# Define the command to run your app
CMD ["node", "server.js"]

