# ObjectCounting-Prototype 🧪

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

1. Enter inside the correct folder
   
    ```bash
   cd frontend
   ```

3. Install dependencies

   ```bash
   flutter pub get
   ```

4. Start the app

   ```bash
    flutter run
   ```

****

## backend:

# flask + opencv
- thesis object counting protype. it has the opencv backend route that takes in the image of the user and processes that to count the object in the provided image.
- the response would be the number of the objects counted within the image and also the appropriate number tags and the corresponding bounding boxes

![sticker-smash (5)](https://github.com/user-attachments/assets/6cda695f-a697-4bb7-ac89-6b6cda28e768)

### in order to run or test this:
- python must also be installed on your machine (tick the `PATH` checkbox before installing python)
- create the `virtual environment`, activate the virtual environment using the `Command Prompt` (make sure you are in the `Scripts` directory where `activate.bat` is located)
- `cd` back to `backend` folder where the  `requirements.txt` is located and then run the command to install the packages
- once you're done with the instructions above, make sure you are in the `backend` folder then run this code in the `Command Prompt`:
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



https://github.com/user-attachments/assets/456a4556-a73a-41df-ace6-baad09fa48f3


# fix_inventory
