# ObjectCounting-Prototype 🧪

## frontend: 
This is an [Expo](https://expo.dev) project created with [`create-expo-app`](https://www.npmjs.com/package/create-expo-app).

## Get started

1. Install dependencies

   ```bash
   npm install
   ```

2. Start the app

   ```bash
    npx expo start
   ```

In the output, you'll find options to open the app in a

- [development build](https://docs.expo.dev/develop/development-builds/introduction/)
- [Android emulator](https://docs.expo.dev/workflow/android-studio-emulator/)
- [iOS simulator](https://docs.expo.dev/workflow/ios-simulator/)
- [Expo Go](https://expo.dev/go), a limited sandbox for trying out app development with Expo

You can start developing by editing the files inside the **app** directory. This project uses [file-based routing](https://docs.expo.dev/router/introduction).

## Get a fresh project

When you're ready, run:

```bash
npm run reset-project
```

This command will move the starter code to the **app-example** directory and create a blank **app** directory where you can start developing.

## Learn more

To learn more about developing your project with Expo, look at the following resources:

- [Expo documentation](https://docs.expo.dev/): Learn fundamentals, or go into advanced topics with our [guides](https://docs.expo.dev/guides).
- [Learn Expo tutorial](https://docs.expo.dev/tutorial/introduction/): Follow a step-by-step tutorial where you'll create a project that runs on Android, iOS, and the web.

## Join the community

Join our community of developers creating universal apps.

- [Expo on GitHub](https://github.com/expo/expo): View our open source platform and contribute.
- [Discord community](https://chat.expo.dev): Chat with Expo users and ask questions.

****

## backend:

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


