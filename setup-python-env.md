## Setting up a Consistent Python Environment

In order to update the WFTDM documentation via quarto on multiple machines, we must maintain consistency with the python dependencies. This markdown provides guidance on on how and which libraries to install.

### Step 1: Create a new python environment & copy libraries

The first step is create a new python environment specific to the WFTDM documentation. Its important to reserve this new environment *for and only for* the WFTDM documentation. If you fail to do so, dependencies may accidently change and break the quarto rendering process.

While creating the environment, you can copy all the libraries and their corresponding versions using the `environment.yml` file. 

To create a new environment with the specific libraries

 - Open up `Anaconda Prompt (Anaconda 3)`
 - Set the working directory to the `TDM-Documentation` folder (*i.e. `D:\GitHub\TDM-Documentation`*)
 - Run `conda env create -n myenv -f environment.yml` replacing `myenv` with your environment name. (*i.e. `wftdm-docs`*)
 - Activate the environment to ensure it worked by running `conda activate myenv`

### Step 2: Update QUARTO_PYTHON path

When you first setup quarto on your machine, you should have set an environment variable for the python it should use. We want to update this path to point to the python within your new environment. 

 - Search `Edit the system and environment variables`
 - Click `Environment Variables`
 - Edit `QUARTO_PYTHON` path under `System variables` to the python path of the new environment you created. (*i.e. `C:\Users\user\Anaconda3\envs\wftdm-docs\python.exe`*)

### Step 3: Restart and Double Check

Since you just updated a system variable, it is good practice to restart your machine to ensure it updates.

 - Restart your machine
 - Open the `TDM-DOCUMENTATION` repository in `VSCode`
 - Click `Terminal\New Terminal` to open a new terminal
 - Run `quarto check jupyter` in the terminal window (you don't have to activate the correct environment, but feel free to do so if you'd like)
 - Ensure the python path is correct


## Updating Python Environment for other Developers

While developing this repository, new packages may need to be installed, and other packages deleted or updated to a different versioning. In order to ensure consistency between developers, its *critical* to regenerate the `environment.yml` file and commit and push to origin. Updating the `environment.yml` file can be done with the following command: `conda env export > environment.yml`. 

After updating the `environment.yml` file, please ensure to let other developers know of the update, so they can rebuild their environment with the updated libraries. 