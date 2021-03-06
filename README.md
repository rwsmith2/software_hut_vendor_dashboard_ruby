# Team9Project
By Ahmed Rashed Alblooshi, Ahmed Yaaqoub Alblooshi, Thomas Damri, Jingxiang Qi,
Boxuan Shan and Ryan Smith.

### Description
Vendor Management Self-Service Platform/Portal
The aim of this project is to create a Proof of Concept for a Vendor Management Self-Service
Platform/Portal to automate task reminders and updates and to allow for Vendors’ performance
information to be uploaded, reviewed, stored and managed, to allow for prospective Vendors to
complete/upload information so that this can be reviewed, assessed and/queried and stored and
to provide an information and/or progress dashboard.

### Significant Features/Technology
The system has the following:

* Registration System
* Assessment Creation
* Task Assignment
* Document Uploads
* Task Scheduling
* Email Notifying

### Admin Manual
The manual for admins using the site can be found in the Team09 google drive(I think you should have access to it).
The manual goes through the basics of how to create assessments, assign tasks and all the other features. 
The manual also goes through in detail how to reset the database and create new admin accounts.

Link to manual- 'https://drive.google.com/file/d/1B44fera9Ea2fASIjLIfaOfLa88QOQKd4/view?usp=sharing'

### Deployment
To deploy the system, you must install the gems using 'bundle install' in console.
Then you must reset and start the database, using 'bundle exec rake db:drop db:create db:migrate' in console.
Doing this will create a new database using the necessary schema.
To start a rails server to run the application, type 'bundle exec rails s' in console. 
Once the server is started, open a web browser and navigate to 'http://localhost:3000/'

Instructions may differ if you are running off a different type of server.

### File Structure
The database schema and migrations file is located in the db folder, inside of the Team9Project main folder. 

Inside the app file, you will find the main bulk of project code, such as controllers, views, models, etc.
The controllers folder(app\controllers) holds all of the controllers we are using. 
The views(app\views) are split into sub-folders, signifying the controller calling them, and which model they relate to. 
Such as the assessments folder of views is connected to the assessments_controller and the assessment model file.
The models folder(app\models) contains all of the model files, but also includes the ability folder, where you can specify what 
users have access to what actions. 

The gemfile is located inside the initial folder, where you can find all the gems installed for the project.

The routes file is located at (config\routes.rb).

The tests are held in the 'spec' folder. 
The unit tests are located at (spec\models) and you can find the tests for the specific model by looking at the name. 
The end-to-end tests are located at (spec\features) and you can find the tests for the specific model by looking at the name.

### How to run tests
You can run all of the unit tests with the command:
  'bundle exec rspec spec/models/"test file name".rb'

You can run all of the end-to-end tests with the command:
  'bundle exec rspec spec/features/"test file name".rb'

### Help Contacts
Ryan Smith <RWSmith2@sheffield.ac.uk>
Thomas Damri <TDamri1@sheffield.ac.uk>
