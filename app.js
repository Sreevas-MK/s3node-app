require('dotenv').config();
const express = require('express');
const AWS = require('aws-sdk');
const multer = require('multer');
const path = require('path');

// Configure AWS SDK to use IAM roles
AWS.config.update({
  region: process.env.AWS_REGION,
});

const s3 = new AWS.S3();
const app = express();
const upload = multer({ storage: multer.memoryStorage() });

// Serve static files
app.use(express.static('public'));

// Set up views
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// Home route
app.get('/', (req, res) => {
  res.render('index');
});

// Upload route
app.get('/upload', (req, res) => {
  res.render('upload');
});

app.post('/upload', upload.single('file'), (req, res) => {
  const file = req.file;
  if (!file) {
    return res.status(400).send('No file uploaded.');
  }

  const params = {
    Bucket: process.env.S3_BUCKET_NAME,
    Key: file.originalname,
    Body: file.buffer,
  };

  s3.upload(params, (err, data) => {
    if (err) {
      console.error(err);
      return res.status(500).send('Error uploading file.');
    }
    res.redirect('/list');
  });
});

// List files route
app.get('/list', (req, res) => {
  const params = {
    Bucket: process.env.S3_BUCKET_NAME,
  };

  s3.listObjectsV2(params, (err, data) => {
    if (err) {
      console.error(err);
      return res.status(500).send('Error listing files.');
    }
    res.render('list', { files: data.Contents });
  });
});

// Download route
app.get('/download/:filename', (req, res) => {
  const filename = req.params.filename;
  const params = {
    Bucket: process.env.S3_BUCKET_NAME,
    Key: filename,
    Expires: 3600, // URL expires in 1 hour
  };

  s3.getSignedUrl('getObject', params, (err, url) => {
    if (err) {
      console.error(err);
      return res.status(500).send('Error generating presigned URL.');
    }
    res.redirect(url);
  });
});

// Start the server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});
