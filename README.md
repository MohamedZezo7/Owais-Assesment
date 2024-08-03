# Owais-Assesment
First, we need to make the application  variables become dynamic to pass it when we write the k8s manifest file ,
So I use the dotenv file and make the all variables store in .env by editing this files in the application code :
(mongo.js - redis.js - sequelize.js - index.js - config.js)
-------
To test the application locally you can run the docker-compose file that locate in nodejs-api-template directory 
# cd nodejs-api-template 
# sudo docker-compose up -d 

------
The Steps : 

1 - Provisiong the infrastructure on AWS using Terraform scripts include ( VPC , EC2 , RDS Database , Security Groups and IAM roles )

This is a Simple Diagram of our Infrastrucure 
![Alt Text](images/AWS%20Diagram.png)

To Run this Infrastrucure You Need to Install Terraform and change the variables that locate ./Terraform/terraform.tfvars to meet your environment variable : 
after that you can run this commands to apply changes after add your aws credentials in ~/.aws/credentials

# cd Terraform 
# terraform init
# terraform plan --var-file terraform.tfvars
# terraform apply --var-file --auto-approve 

after that you that the infrastructure is provisioned and the terraform state file store at your s3 bucket and lock file in dynamodb

--------------------------------------------

2 - Use Ansible as a COnfiguration Management tool to Configure our ubuntu server with nginx & let`s encrypt and Firewall Rules : 
 change the variables with your variabales in ( ansible.cfg, inventory.ini, playbook.yml, roles variables)
cd ansible 

To Check the Syntax
# ansible-playbook playbook.yml syntax-check

ping the server
# ansible all -i inventory.ini -m ping

run the playbook 

# ansible-playbook -i inventory.ini playbook.yml

---------------------------------------------------------------------------------------------

After this two stages , we go through write the Dockerfile to build the image and push the first image of our api to Dockerhub : 
 the first image name at Dockerhub : mohamedabdelaziz10/owais-backend:v1 

 - Now we can Write the Kubernetes Manifest file that will run on minikube  on ec2 with Horizontal Pod AutoScaler and Netwrok Policy 
 you can check the manifest files at k8s/ Directory

 -------------
Unfortunately, my Amazon account was closed while I was implementing the project, so I built the environment on Microsoft Azure cloud with the same environment that i discuss it above 

I don't currently have a domain, so I'm working in a development environment with server ip address 
( this is not on production environment ) 
 ---------------------------------------------

 Now everything is ok to configure our Jenkins Server you can check the Jenkins Configuration at this endpoint : http://135.237.120.226:8080 
 
 and the Jenkins file ./Jenkinsfile 

 ------------------------

After Running the Pipeline and apply the k8s manifest files the app is available at nodeport http://192.168.49.2:30003 so we use Nginx as reverse Proxy 
to listen on port 80 and to access the private app : 

app url : http://135.237.120.226:80

Note : I can`t give the app certificate because the free domains have high latency but in production we buy a domain and give it certificate 

-----------------------------------------

- Now we need Monitoring and Logging stack to our Application so we use : 
 
  Prometheus, Grafana, NodeExporter, Blackbox Exporter to Monitor our application status & Jenkins Metrics & The Server Metrics 

  So Now We Need to Write Docker-compose.yml and create three dashboards to application status & Jenkins Metrics & The Server Metrics

  Prometheus Endpoint : http://135.237.120.226:9090
  Grafana Endpoint : http://135.237.120.226:3000 
  (usenname : admin
   password : owais-grafana-pw
 )

 -------

  Prometheus Targets : 

  ![Alt Text](images/Prometheus-Metrics.png)





 This is the Three Dashboards : 
  
   1 - Application health check Dashboard 

![Alt Text](images/Grafana-blackbox.png)


   2 - Server Metrics Dashboard 
![Alt Text](images/Server-Dashboard.png)


   3 - Jenkins Performance and Health 
![Alt Text](images/Jenkins-Dashboard.png)



--------------------------------

Testing API :

![Alt Text](images/Testing-api.png)