# Innolink

Innolink is a platform that connects individuals with innovative ideas to potential investors, fostering a global startup community. It provides a space for idea sharing, brainstorming, and collaboration to help ideas reach their full potential. Innolink enables innovators and investors to come together seamlessly, creating opportunities for investment and partnerships. Our mission is to create a world where every idea holds value and can be transformed into impactful startups.

## Features

- **Post Innovative Ideas**: Share your groundbreaking ideas with the community.
- **Like and Comment**: Interact with others' ideas by liking and commenting.
- **Handshakes**: Form connections (similar to Facebook friends) to collaborate on ideas.
- **Invest**: Potential investors can support ideas and help bring them to life.

## Prerequisites

To run this project, you will need the following installed on your system:

- [Ballerina](https://ballerina.io/) (for backend services)
- [Node.js](https://nodejs.org/en/download/) (for frontend)
- MySQL database

## Setup Instructions

### 1. Clone the Repository

First, clone the project repository to your local machine:

```
git clone https://github.com/ThisaraWeerakoon/iwb127-compiler_titans.git
cd iwb127-compiler_titans
```
#### Project Structure

```
backend/
   └── social_media_service/
       ├── social_media_service/
       ├── script.sql (Database schema)
frontend/
   ├── React-based frontend
```

### 2. Run script.sql 

Setup mysql by executing script.sql script.

### 3. Configure the MySQL Database

Access `/backend/social_media_service/Config.toml`, configure the following details MySQL server credentials:

```
[social_media_service]
   host = "localhost"
   port = 3306
   user = "root"
   password = ""
   database = "innolink_db"
```

### 4. Start the Backend Server

```
cd backend
cd social_media_service
bal run
```
### Frontend Setup
1. **Install Frontend Dependencies**:

   Navigate to the frontend folder and install the required dependencies:

   ```bash
   cd frontend
   npm install
   ```
2. **Start the Frontend Server**

   ```bash
   npm run dev
   ```









## Running the Application

After setting up both the backend and frontend, the application should be running at:

- **Backend**: `http://localhost:9090` (default Ballerina service port)
- **Frontend**: `http://localhost:5173` (default Vite port)

You can access the frontend to interact with the platform.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

```
This `README.md` covers the basic idea of the project, setup instructions, and provides a project overview. Let me know if you need any changes!
```





