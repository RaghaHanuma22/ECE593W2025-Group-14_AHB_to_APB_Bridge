# Group 14 - AHB to APB Bridge

Implementation of AHB to APB Bridge for ECE-593 (Pre-Silicon Validation)

# UVM Testbench Architecture
![UVM_TB_Arch](https://github.com/user-attachments/assets/ef21055b-2b6b-49ae-a334-41ad5d257762)



# Contributing to the project
## Basic Workflow
1. Clone the repository
```bash
git clone https://github.com/RaghaHanuma22/ECE593W2025-Group-14_AHB_to_APB_Bridge.git
```
2. Create a branch for your feature/task
```bash
#Exmaple
git checkout -b feature/AHB2APB_FSM_Controller 
```
3. Make changes and commit
```bash
git add .
git commit -m "Descriptive message about changes"
```
4. Push your branch to the remote repository
```bash
git push origin feature/AHB2APB_FSM_Controller 
```
5. Creat a Pull Request (PR) on GitHub when your feature is complete
This step is as follows: 
- Go to your GitHub repository in your web browser. You should see a yellow banner near the top with your recently pushed branch, with a green button that says  
"Compare & pull request". Click that button.
- If you don't see this banner, you can click on "Pull requests" tab, then the green "New pull request" button
Then select your project-structure branch to compare against main
- Fill out the PR form:
    - Write a clear title describing your change
    - In the description, explain what changes you made and why
    - GitHub will automatically show you if there are any merge conflicts
    - Click "Create pull request"
- After creating the PR:
    - We all  can review the code, leave comments or request changes
    - Once approved, you or someone else  can merge it into main

# After PR is merged
```bash
git checkout main
git pull  # Get latest including your merged changes
```

#Notes
If for some reason when pushing to your branch if it doesn't work, do the following
```bash
git push --set-upstream origin <branch-name>
```
