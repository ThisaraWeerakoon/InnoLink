# API Documentation for Authentication Service

## Base URL

**Base Path**: `/api/auth`

This authentication service provides endpoints for logging in and registering users with JWT token issuance for user authentication.

---

## 1. **Login User**

### **Endpoint**

```
GET /api/auth/login
```

### **Description**
Logs in a user by verifying email and password. Returns a JWT token and user details upon successful login.

### **Request Parameters**

| Name       | Type   | Description          | Required |
|------------|--------|----------------------|----------|
| `email`    | String | The email of the user | Yes      |
| `password` | String | The user's password   | Yes      |

### **Response**

| Status Code       | Description                                                    |
|-------------------|----------------------------------------------------------------|
| **200 OK**        | Returns user details and JWT token in a JSON format            |
| **400 BadRequest**| When user does not exist, or password is incorrect             |
| **500 InternalServerError** | If an error occurs during database interaction        |

### **Response Example**
```json
{
  "userData": {
    "id": "some-uuid",
    "name": "John Doe",
    "email": "john@example.com",
    "profilePicture": "http://path.to/profilepic"
  },
  "token": "eyJhbGciOi... (JWT Token)"
}
```

### **Error Response Example**

```json
{
  "message": "User does not exist"
}
```

```json
{
  "message": "Wrong password"
}
```

### **JWT Issuance Process**
Upon successful login, a JWT token is issued using the following configuration:
- **Issuer**: `socialMediaApp`
- **Audience**: `users`
- **Expiration**: `3600` seconds

---

## 2. **Register User**

### **Endpoint**

```
POST /api/auth/register
```

### **Description**
Registers a new user. Checks if the email is already registered and inserts a new user into the database. Returns a JWT token upon successful registration.

### **Request Body**

| Field Name         | Type    | Description                            | Required |
|--------------------|---------|----------------------------------------|----------|
| `first_name`        | String  | User's first name                      | Yes      |
| `last_name`         | String  | User's last name                       | Yes      |
| `email`            | String  | User's email                           | Yes      |
| `password`         | String  | User's password                        | Yes      |
| `dob`              | String  | User's date of birth (ISO format)       | Yes      |

### **Request Example**

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john@example.com",
  "password": "password123",
  "dob": "1990-01-01"
}
```

### **Response**

| Status Code       | Description                                                    |
|-------------------|----------------------------------------------------------------|
| **200 OK**        | Returns the JWT token                                          |
| **400 BadRequest**| If the email already exists or registration fails              |
| **500 InternalServerError** | If an error occurs during database interaction        |

### **Response Example**

```json
"eyJhbGciOi... (JWT Token)"
```

### **Error Response Example**

```json
{
  "message": "User already exists"
}
```

```json
{
  "message": "Failed to register user"
}
```

---

## **Utility Functions**

### **Hash Password**

The `hashPassword` function uses the SHA-256 hashing algorithm to hash the user's password before storing it in the database.

```ballerina
isolated function hashPassword(string password) returns string
```

- **Input**: Plaintext password (`string`)
- **Output**: Hashed password (`string`)

### **Compare Password**

The `comparePassword` function compares a given plaintext password to a hashed password.

```ballerina
isolated function comparePassword(string inputPassword, string storedHashedPassword) returns boolean
```

- **Input**: 
  - `inputPassword`: The plaintext password entered by the user.
  - `storedHashedPassword`: The hashed password stored in the database.
- **Output**: `true` if the passwords match, `false` otherwise.

---

## **CORS Configuration**

This service allows cross-origin requests with the following settings:

- **Allowed Origins**: `*`
- **Allow Credentials**: `true`
