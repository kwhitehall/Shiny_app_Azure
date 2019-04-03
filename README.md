# Shiny_app_Azure
End to end deployment of R Shiny in Azure using Docker, Azure Container Registry and Azure Web Apps
Also used Azure DSVM Linux box during this process.
The R code for the Shiny App is leveraged from the article ["How to select the best performing linear regression for univariate models"](https://medium.freecodecamp.org/learn-how-to-select-the-best-performing-linear-regression-for-univariate-models-e9d429c40581).

## Steps
### A: Get your R code together
1. In the [Portal](www.portal.azure.com), deploy a Data Science Virtual Machine (DSVM) with Ubuntu. As the Azure DSVMs come with Docker, R, Azure CLI and other useful tools already installed, this will be used as our working environment.
2. Log into the VM, create a folder for the app - **My_app**
3. Grab the R code for the Shiny App from the [Björn Bos' Github repo](https://github.com/bjoernbos/linear_model_selection) and unzip into **My_app**
4. Create a [Dockerfile](https://github.com/kwhitehall/Shiny_app_Azure/blob/master/Dockerfile) in the main folder **My_app**. [Dockerfile](https://github.com/kwhitehall/Shiny_app_Azure/blob/master/Dockerfile) given here is a template leveraged from the [official source](https://github.com/rocker-org/shiny).
5. Add configuration files for the Shiny app – [shiny_server.conf](https://github.com/kwhitehall/Shiny_app_Azure/blob/master/shiny-server.conf) and [shiny-server.sh](https://github.com/kwhitehall/Shiny_app_Azure/blob/master/shiny-server.sh) from above to the folder **My_app**. The file structure should look like: 

            My_appp
              - app/
                  - server.R
                  - ui.R
                  - global.r
                  - about.html
                  - data.csv
              - Dockerfile
              - shiny-server.conf
              - shiny-server.sh
                  
### B: Build the Docker image
6. Navigate to your folder **My_app** and run the following command
      ``` 
      docker build -t My_app . 
      ```

### C: Deploy the app online
#### Deploy in DSVM 
7.	Open up the port on your DSVM to allow the traffic using Azure CLI. For this app we use port 3838.

      ```
      az login
      ```
    
Once you have successfully logged in, type:

      ```
      az vm open-port -g <resource group> -n <VM name> --port <port#> --priority 901
      ```
    
8.	Run the Docker image

      ```
      docker run -p port_num:port_num My_app
      ```
    
Up to this point, your app is available to anyone online via the DSVM URL (www.DSVM_IP:3838). But here we assume that this DSVM will be decommissioned so we need to host our app elsewhere.

#### OR Transfer Shiny App to a web server and deploy online
Login to the Azure CLI  

      ```
      az login
      ```
9.	Save Docker image as a tar file

      ```
      docker save -o ~/my_shinyapp.tar my_shinyapp
      ```
    
10.	Deploy image on webserver: copy file to server and run it

      ```
      docker load -i my_shinyapp.tar
      docker run my_shinyapp 
     ```
You may need to open up the port on the webserver on your own. Up to this point then, your app would be available to anyone online via the webserver URL (www.webserver_IP).

#### OR Deploy in PaaS environment leveraging ACR and Web Apps     
11.	Add docker container to Azure Container Registry.
(So now we have our docker container, let’s utilize Azure Container Registry (ACR) for private container management. Azure Container Registry is your private Docker registry in Azure.) These steps can also be completed on [command line]( https://docs.microsoft.com/en-us/azure/container-instances/container-instances-tutorial-prepare-acr) 

a. Create ***Azure Container Registry*** in the Portal.
    
b. Log into the container registry

   i.       az acr login --name <my_acr_name>

c. Grab the login server for the registry from the Overview section (It should be format *www.<my_acr_name>.azurecr.io*)

d. Tag the docker image and push
    
   i.	Use ``` docker images ```  to get the image you wish
        
   ii.	``` docker tag my_shinyapp <my_acr_name>.azurecr.io/my_shinyapp:v1 ```
        
   iii.	Push the image to the ACR. Before running this, check the previous step was successful by running docker images again
      ```
      docker push <my_acr_name>.azurecr.io/my_shinyapp:v1
      ```            
 e.	Verify the image has been pushed in the portal by looking under the Repositories for your app. (Or using Azure CLI commands)   
 e.	Turning on permissions for the last step: In the Portal, navigate to the ***Access keys*** under ***Settings*** and click “Enable” under Admin user (this is necessary to log in with Docker). 
    
12.	Deploy container via Azure Web App for Container.
In Portal create the resource ***Web App for containers***. The name that your choose where will be the name of your app i.e. myShiny.azurewebsites.net. Make container a Linux container.  Choose the appropriate App service plan. In Configure container for image source, choose Azure Container Registry.

a.          Choose the correct ACR from the dropdown box

b.          Choose the correct image.

c.	The tag i.e. version. (v1 in this example. If none was added, the tag is latest by default)

d.	Deploy the resource

**Access your app online! Navigate to www.<your_app_name>.azurewebsites.net**
At this point, you can tear down the DSVM if you haven't already. 
