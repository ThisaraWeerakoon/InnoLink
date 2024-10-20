# InnoLink
Ballerina Competition Startup Social Media Application


Here is the **API Documentation** in **Markdown (markup) language** format:

---

# Authentication Service API - Social Media App

This API provides authentication services for a social media application. It allows users to log in, register, and manage authentication tokens via JWT (JSON Web Token).

## Table of Contents
- [Base URL](#base-url)
- [Endpoints](#endpoints)
  - [Login](#1-login)
  - [Register](#2-register)
- [Request & Response Formats](#request--response-formats)
- [Error Handling](#error-handling)
- [Authentication](#authentication)
- [Security](#security)
- [Hashing & Passwords](#hashing--passwords)

## Base URL

`https://your-domain.com/api/auth`

This is the base URL for all the authentication-related APIs.

## Endpoints

### 1. Login

**Endpoint**: `/api/auth/login`  
**Method**: `GET`

**Description**: Allows users to log in using their email and password. On successful authentication, the API returns the user’s profile data and a JWT token for subsequent authenticated requests.

#### Request Parameters

- `email`: (string) The user's email address.
- `password`: (string) The user's password.

#### Example Request

```http
GET /api/auth/login?email=john.doe@example.com&password=yourPassword123
```

#### Successful Response

- **Status**: `200 OK`
- **Content-Type**: `application/json`

```json
{
  "userData": {
    "id": "12345",
    "name": "John Doe",
    "email": "john.doe@example.com",
    "profilePicture": "https://example.com/profile_pics/john.jpg"
  },
  "token": "eyJhbGciOiJIUzI1NiIsIn..."
}
```

#### Error Response

- **Status**: `400 BadRequest`

```json
{
  "message": "User does not exist"
}
```

or

```json
{
  "message": "Wrong password"
}
```

---

### 2. Register

**Endpoint**: `/api/auth/register`  
**Method**: `POST`

**Description**: Allows new users to register with the platform by providing their basic details. Upon successful registration, the API issues a JWT token for immediate use.

#### Request Body

The `registerUser` object is required in the request body.

#### Example of Request Body

```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "john.doe@example.com",
  "dob": "1990-01-01",
  "password": "securePassword123"
}
```

#### Successful Response

- **Status**: `200 OK`
- **Content-Type**: `application/json`

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsIn..."
}
```

#### Error Response

- **Status**: `400 BadRequest`

```json
{
  "message": "User already exists"
}
```

or

```json
{
  "message": "Failed to register user"
}
```

---

## Request & Response Formats

- **Content-Type**: The API accepts and returns JSON.
- **Authorization**: Use the JWT token received during login for all authenticated requests in the `Authorization` header.

```http
Authorization: Bearer <your-token>
```

## Error Handling

The API follows a consistent error format across all endpoints. Errors are returned with an HTTP status code and a JSON object providing details of the error.

#### Example Error Response

```json
{
  "message": "User already exists"
}
```

---

## Authentication

This API uses **JWT (JSON Web Tokens)** for secure authentication. Once the user successfully logs in or registers, a JWT token is issued. This token must be included in the `Authorization` header of subsequent requests to protected resources.

#### Example JWT Token Format

```json
"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

### Token Structure

- **Header**: Specifies the type of token and hashing algorithm.
- **Payload**: Contains user data (e.g., user ID, email).
- **Signature**: Verifies the token wasn’t tampered with.

---

## Security

- Passwords are **never stored in plain text**. They are hashed using the `SHA-256` algorithm before being stored in the database.
- Authentication tokens (JWTs) are signed with a private key and should be validated on every protected request.
- CORS (Cross-Origin Resource Sharing) is configured to allow requests from all origins, but with credentials.

---

## Hashing & Passwords

- **Hashing**: The `hashPassword` function hashes user passwords using SHA-256 and converts the hashed value into a hexadecimal string for storage in the database.
- **Password Comparison**: The `comparePassword` function compares the user's input password by hashing it and comparing it with the stored hashed password.

#### Example of Password Hashing in Ballerina

```ballerina
isolated function hashPassword(string password) returns string {
    byte[] hashedPassword = crypto:hashSha256(password.toBytes());
    return hashedPassword.toBase16();  // Convert to hexadecimal for storage
}
```

#### Example of Password Comparison in Ballerina

```ballerina
isolated function comparePassword(string inputPassword, string storedHashedPassword) returns boolean {
    string hashedInputPassword = hashPassword(inputPassword);
    return hashedInputPassword == storedHashedPassword;
}
```

---

### Notes

- The private key for JWT signing is located at `./resources/private.key` in the configuration. Ensure this key is secure and properly configured.
- JWT tokens are set to expire in `3600` seconds (1 hour).

---

This concludes the API documentation for the authentication service.


