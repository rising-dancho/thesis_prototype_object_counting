# flask + opencv
- thesis object counting protype. it has the opencv backend route that takes in the image of the user and processes that to count the object in the provided image.
- the response would be the number of the objects counted within the image and also the appropriate number tags and the corresponding bounding boxes

![processed_image (1)](https://github.com/user-attachments/assets/d290c9b3-b782-4af4-8404-ee4340077bde)

### in order to run or test this:
- python must also be installed on your machine (tick the `PATH` checkbox before installing python)
- create the `virtual environment`, activate the virtual environment using the `Command Prompt` (make sure you are in the `Scripts` directory where `activate.bat` is located)
- `cd` back to `backend` folder where the  `requirements.txt` is located and then run the command to install the packages
- once you're done with the instructions above, make sure you are in the `backend` folder and your `XAMPP` is running. And then run this code in the `Command Prompt`:
  `python app.py`
- finally, install `Postman` so that you can test the `/process-image` route

### creating the virtual environment
```
python -m venv venv
```

### activating the virtual environment: (run in command prompt)
```
cd .venv/Scripts
activate.bat
```

### installing packages from the requirements.txt
```
pip install -r requirements.txt
```

### gitignore must include

```
# Python-related files
*.pyc
__pycache__/
*.pyo
*.pyd
*.egg-info/
*.egg
pyvenv.cfg

# Ignore backend-specific Python cache
backend/__pycache__/

# Ignore virtual environments
.venv/
venv/
env/

# Ignore site-packages if using a relative path
Lib/site-packages/

# OS or IDE-specific files
.DS_Store
*.log

# IDE-specific files (e.g., for VSCode)
.vscode/

# Windows image file caches
Thumbs.db

```

### creating requirements.txt
```
pip freeze > requirements.txt
```
****
