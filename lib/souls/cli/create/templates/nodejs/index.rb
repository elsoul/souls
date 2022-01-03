module Template
  module Nodejs
    def self.index(file_name)
      <<~APP
        const express = require('express');
        const bodyParser = require('body-parser');

        const app = express();
        app.use(bodyParser.urlencoded({ extended: true }));

        app.get('/souls-functions-get', (req, res)=>{
          res.json(req.query)
        });

        app.get('/souls-functions-get/:id', (req, res)=>{
          res.json(req.params)
        });

        app.post('/souls-functions-post', (req, res)=>{
          res.json(req.body)
        });
        exports.#{file_name} = app;
      APP
    end
  end
end
