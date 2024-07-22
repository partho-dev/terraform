
### Use Jenkins to CI Terraform to build infra

![Terraform-CICD-Jenkins](https://github.com/user-attachments/assets/02984cd9-31f1-456e-a88f-519e11c64a07)

- Assumptions
    - The target cloud provider is AWS
    - The Jenkins is installed in an instance on the same AWS account
- Prerequisite
    1. Create an IAM user with policy to access aws resources - start with `AdministratorAccess`
        - Make a note of the access-key and secret-access-key

    <img width="1334" alt="policy" src="https://github.com/user-attachments/assets/f02a4cf4-c22a-497a-aa31-2df7477d4631">

    2. create an IAM role for Ec2 to have full access to control the AWS infra
    <img width="417" alt="role" src="https://github.com/user-attachments/assets/d0b788eb-dfcf-4632-ac64-0a1320375280">

- Create an Ec2 instance from AWS Console  [ Later we will create the EC2 using terraform ]
- I am using ubuntu OS with t2.small instance and 20 GB GP2 EBS
- Attach the role to that Ec2
<img width="856" alt="attach-role" src="https://github.com/user-attachments/assets/b9d8d441-c6b2-4887-b522-cbf62512e901">

- ssh to the Ec2 instance and install the necessary packages
### Update the ubuntu & install Java 
- sudo apt update
- sudo apt install openjdk-11-jre -y
- java -version [Check if Java is installed properly]

### Install the Jenkins 
```
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins
```
- Check the jenkins installed or not `jenkins --version`

### Now open port 8080 on the instance SG

### Login to the Jenkins 
- Open browser and type the public IP of the instance with :8080
- ex: `http://13.201.8.60:8080/`
<img width="930" alt="Jenkins-Login" src="https://github.com/user-attachments/assets/d78dd417-1ee9-4008-9a2b-f8644a45e5f4">

- Get the password and login to Jenkins by typing this command on the instance console `sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
- Install all suggested plugins 
<img width="825" alt="Jenkins-package-install" src="https://github.com/user-attachments/assets/771d266e-8387-497e-960f-61ff633fe3e6">

- Ensure to change the user/pass

## Configure the Jenkins for Terraform
1. Install Terraform plagins
- Click on "Manage Jenkins" & then click on "Plugins"
<img width="1672" alt="manage-jen" src="https://github.com/user-attachments/assets/de52f842-4b0f-4f49-a98a-3703dd591369">

- click on "Available Plugins" & on the search type - `terraform`
- select the box and click on install
<img width="1273" alt="install-terraform" src="https://github.com/user-attachments/assets/2e80573f-1c2e-4a98-8725-cefbee714211">

2. Now, we need to install Terraform Binary
- Binaries are needed to work with plugins
- Click on `Dashboard` then click on `Manage Jenkins` & then click on `Tools`
- <img width="570" alt="tf-01" src="https://github.com/user-attachments/assets/7e1a93e2-10c0-44e4-9852-b22496523804">
- Scroll down and find "Terraform installations"
- Give some name on the name field, I gave "terraform"
- select install automatically and click "apply" & "save"

- SOmetimes, the above method of terraform installation does not properly install terraform on Jenkins server
- So, try manual installation - https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli


3. Now, its the time to create the declerative pipeline
- Click on "New Items" & Select "pipeline" and give a name
- <img width="323" alt="pipeline-01" src="https://github.com/user-attachments/assets/87ceb9b3-7c8e-45ef-ab89-bc726660380f">
- <img width="587" alt="pipeline-02" src="https://github.com/user-attachments/assets/d00db9cb-fb42-4d33-b50f-9d7f531927b1">
- We will get this configuration page and here all the settings need to put
<img width="1547" alt="pipeline-03" src="https://github.com/user-attachments/assets/b76ffe6b-2f7e-4aeb-aaa0-8222d5984f6c">

- scroll down to `pipleline` section 
    - If we want to keep the `Jenkinsfile` on our Jenkins server, we can select `pipeline script `
    - If we want the `Jenkinsfile` on github and it automatically reads that upon checkout, we will select `pipeline script from scm`

4. Push the code to github
<img width="774" alt="pipeline-04" src="https://github.com/user-attachments/assets/f90a218e-4d66-44be-aa91-c66ca35ae3bf">

- There may be an issue while pushing the terraform files into github and the error may be
```
remote: error: File .terraform/plugins/darwin_amd64/terraform-provider-aws_v2.1.0_x4 is 134.07 MB; this exceeds GitHub's file size limit of 100.00 MB
```

- Adding .terraform/ into .gitignore may not solve the problem 
- Or these bellow troubleshooting would not help
```
git rm -r --cached <filePath>
git reset -r -- <filePath>
# rm all files
git rm -r --cached .
# add all files as per new .gitignore
git add .
# now, commit for new .gitignore to apply
git commit -m ".gitignore is now working"
```
- To solve that, we can execute this `git filter-branch -f --index-filter 'git rm --cached -r --ignore-unmatch .terraform/'`

5. Lets write the `Jenkins` file
- <img width="1192" alt="pipeline-05" src="https://github.com/user-attachments/assets/16d2aa6a-ae01-4b41-a5d9-f55f7b0838cb">
- We can either use the sample script to start with or we can use the `Pipeline Syntax` and write each steps seperately
- I am updating the jenkinsfile, which I have taken from this opensource repo `https://github.com/yeshwanthlm/Terraform-Jenkins/blob/main/Jenkinsfile`

6. Lets update the credentials for the Jenkins to connect with AWS
<img width="920" alt="pipeline-06" src="https://github.com/user-attachments/assets/9d6d1dea-eae8-490f-a9c7-c9c9b13b32ec">

- Go to this path Dashboard > Manage Jenkins > Credentials > System
- Click on Add credentials on right top corner
- select `kind` as `secret text`

7. Run the build

<img width="1179" alt="pipeline-07" src="https://github.com/user-attachments/assets/8d049327-a51e-4597-811d-35fd83371888">
<img width="804" alt="pipeline-08" src="https://github.com/user-attachments/assets/2ed4ce77-7f4d-4584-8ad1-2b0ff81fc1ee">
