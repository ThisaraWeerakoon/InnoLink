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


# API Documentation for Comments Service

## Base URL

**Base Path**: `/api/comments`

This service provides various endpoints for managing comments in the social media app, including fetching, adding, and deleting comments. JWT token validation is required for all operations.

---

## 1. **Get All Comments for a Post**

### **Endpoint**

```
GET /api/comments/getallbypost
```

### **Description**
Retrieves all comments for a specific post, given the `postId`.

### **Request Parameters**

| Name     | Type   | Description               | Required |
|----------|--------|---------------------------|----------|
| `postId` | String | The ID of the post         | Yes      |
| `jwt`    | String | JWT token for authentication | Yes    |

### **Response**

| Status Code        | Description                                                     |
|--------------------|-----------------------------------------------------------------|
| **200 OK**         | Returns a list of comments associated with the post             |
| **400 BadRequest** | If the JWT validation fails or there is an error fetching comments |
| **500 InternalServerError** | If there is an issue with database interaction          |

### **Response Example**

```json
[
    {
        "id": "comment-id-1",
        "userId": "user-id-1",
        "postId": "post-id-1",
        "content": "Great post!",
        "created_at": "2024-01-01T00:00:00Z",
        "media": null
    }
]
```

---

## 2. **Get Comment by ID**

### **Endpoint**

```
GET /api/comments/getbyid/{id}
```

### **Description**
Fetches a single comment by its `id`.

### **Request Parameters**

| Name  | Type   | Description               | Required |
|-------|--------|---------------------------|----------|
| `id`  | String | The ID of the comment      | Yes      |
| `jwt` | String | JWT token for authentication | Yes    |

### **Response**

| Status Code        | Description                                      |
|--------------------|--------------------------------------------------|
| **200 OK**         | Returns the comment details                      |
| **404 NotFound**   | If the comment is not found                      |
| **400 BadRequest** | If the JWT validation fails or there is an error |

### **Response Example**

```json
{
    "id": "comment-id-1",
    "userId": "user-id-1",
    "postId": "post-id-1",
    "content": "Nice post!",
    "created_at": "2024-01-01T00:00:00Z",
    "media": null
}
```

---

## 3. **Get All Comments by User**

### **Endpoint**

```
GET /api/comments/getallbyuser
```

### **Description**
Fetches all comments made by a specific user.

### **Request Parameters**

| Name    | Type   | Description               | Required |
|---------|--------|---------------------------|----------|
| `userId` | String | The ID of the user         | Yes      |
| `jwt`    | String | JWT token for authentication | Yes    |

### **Response**

| Status Code        | Description                                     |
|--------------------|-------------------------------------------------|
| **200 OK**         | Returns a list of comments made by the user     |
| **400 BadRequest** | If the JWT validation fails or there is an error |

### **Response Example**

```json
[
    {
        "id": "comment-id-1",
        "userId": "user-id-1",
        "postId": "post-id-1",
        "content": "Interesting!",
        "created_at": "2024-01-01T00:00:00Z",
        "media": null
    },
    {
        "id": "comment-id-2",
        "userId": "user-id-1",
        "postId": "post-id-2",
        "content": "I agree!",
        "created_at": "2024-01-02T00:00:00Z",
        "media": null
    }
]
```

---

## 4. **Add a Comment**

### **Endpoint**

```
POST /api/comments/add
```

### **Description**
Adds a new comment to a post.

### **Request Parameters**

| Name       | Type   | Description                         | Required |
|------------|--------|-------------------------------------|----------|
| `userId`   | String | The ID of the user making the comment | Yes      |
| `postId`   | String | The ID of the post                   | Yes      |
| `content`  | String | The content of the comment           | Yes      |
| `jwt`      | String | JWT token for authentication         | Yes      |

### **Response**

| Status Code            | Description                                         |
|------------------------|-----------------------------------------------------|
| **200 OK**             | Returns the ID of the newly created comment         |
| **400 BadRequest**     | If the JWT validation fails or invalid comment data |
| **500 InternalServerError** | If there is an error while saving the comment  |

### **Response Example**

```json
"comment-id-1"
```

---

## 5. **Delete a Comment by ID**

### **Endpoint**

```
DELETE /api/comments/delete/{id}
```

### **Description**
Deletes a comment by its `id`.

### **Request Parameters**

| Name  | Type   | Description               | Required |
|-------|--------|---------------------------|----------|
| `id`  | String | The ID of the comment      | Yes      |
| `jwt` | String | JWT token for authentication | Yes    |

### **Response**

| Status Code        | Description                                      |
|--------------------|--------------------------------------------------|
| **200 OK**         | Returns the deleted comment details              |
| **404 NotFound**   | If the comment is not found                      |
| **400 BadRequest** | If the JWT validation fails or there is an error |

### **Response Example**

```json
{
    "id": "comment-id-1",
    "userId": "user-id-1",
    "postId": "post-id-1",
    "content": "This comment was deleted.",
    "created_at": "2024-01-01T00:00:00Z",
    "media": null
}
```

---

## **JWT Validation**

All endpoints require JWT token validation. The JWT is validated using the following payload:
- **Payload**: Verified against the provided JWT token.

# API Documentation for Education Service

This service handles the operations related to the **education** section of a user's profile in a social media-like application. All endpoints require a valid **JWT token** for authentication.

---

#### **1. Get Education by ID**
- **Endpoint**: `/api/education/getbyid/{id}`
- **Method**: `GET`
- **Description**: Retrieve a specific education entry by its ID.
- **Parameters**:
  - `id` (Path): The ID of the education record to retrieve.
  - `jwt` (Query): JWT token for authentication.
- **Responses**:
  - **200 OK**: Returns a JSON object containing the education entry.
  - **404 Not Found**: If the education record is not found.
  - **Error**: If JWT validation fails or there is any other error.
- **Sample Response**:
  ```json
  {
    "education_object_by_id": {
      "id": "UUID",
      "institution": "Example University",
      "degree": "Bachelor's",
      "start_year": "2020",
      "end_year": "2024",
      "field_of_study": "Computer Science",
      "userId": "user123"
    }
  }
  ```

---

#### **2. Add Education**
- **Endpoint**: `/api/education/addEducation`
- **Method**: `POST`
- **Description**: Add a new education entry for a user.
- **Parameters**:
  - `userId` (Query): The ID of the user for whom the education record is being added.
  - `neweducation` (Body): JSON object containing the details of the new education entry.
  - `jwt` (Query): JWT token for authentication.
- **Request Body Example**:
  ```json
  {
    "institution": "Example University",
    "start_year": "2020",
    "end_year": "2024",
    "degree": "Bachelor's",
    "field_of_study": "Computer Science"
  }
  ```
- **Responses**:
  - **200 OK**: Returns the `id` of the newly added education record.
  - **400 Bad Request**: If there is a validation issue or constraint violation.
  - **500 Internal Server Error**: For any server errors during the operation.
- **Sample Response**:
  ```json
  {
    "education_id": "generated-uuid"
  }
  ```

---

#### **3. Get Education by User ID**
- **Endpoint**: `/api/education/geteducationbyuserid`
- **Method**: `GET`
- **Description**: Retrieve all education entries associated with a specific user.
- **Parameters**:
  - `userId` (Query): The ID of the user.
  - `jwt` (Query): JWT token for authentication.
- **Responses**:
  - **200 OK**: Returns a JSON object containing the number of education records and the list of education entries.
  - **400 Bad Request**: If there are no records found for the user or other errors.
  - **Error**: If JWT validation fails or there is any other error.
- **Sample Response**:
  ```json
  {
    "education_count": 2,
    "education_records": [
      {
        "id": "uuid-1",
        "institution": "Example University",
        "start_year": "2020",
        "end_year": "2024",
        "degree": "Bachelor's",
        "field_of_study": "Computer Science",
        "userId": "user123"
      },
      {
        "id": "uuid-2",
        "institution": "Another University",
        "start_year": "2016",
        "end_year": "2020",
        "degree": "Master's",
        "field_of_study": "Data Science",
        "userId": "user123"
      }
    ]
  }
  ```

---

### **JWT Token Validation**
For every endpoint, the JWT token is validated using `jwt:validate(jwt, validatorConfig)`:
- If the token is valid, the operation proceeds.
- If the token is invalid or expired, an error message is returned with the appropriate HTTP status.

### Error Handling
- **404 Not Found**: Returned when a resource (such as an education entry) cannot be found.
- **400 Bad Request**: Returned for constraint violations, bad input, or missing data.
- **500 Internal Server Error**: Returned for unexpected server-side errors.

---
# API Documentation for Handshake Service

This API documentation defines several endpoints for managing handshake connections in a social media application using the Ballerina framework. The JWT token is used for authentication, and the handshake functionality allows users to send and receive connection requests, track the status, and manage existing connections.

### Endpoints Overview

#### 1. `GET /api/handshakes/getbyid/{id}`
- **Description**: Retrieves a handshake object by `handshake_id`.
- **Input**: 
  - `id` (Path parameter): Handshake ID.
  - `jwt` (Query parameter): JWT token for authentication.
- **Response**:
  - `200 OK`: Returns the handshake object.
  - `404 Not Found`: If no handshake exists for the given ID.
  - `401 Unauthorized`: If the JWT validation fails.

#### 2. `GET /api/handshakes/getAcceptedHandshakeUsersById`
- **Description**: Retrieves the users that have accepted handshakes from a specific user.
- **Input**: 
  - `userId` (Query parameter): The ID of the user to check.
  - `jwt` (Query parameter): JWT token for authentication.
- **Response**:
  - `200 OK`: Returns a JSON object containing the handshake count and user objects.
  - `400 Bad Request`: If there is an issue retrieving handshakes.
  - `401 Unauthorized`: If the JWT validation fails.

#### 3. `POST /api/handshakes/add`
- **Description**: Adds a new handshake connection between two users.
- **Input**:
  - `handshakerId` (Query parameter): The user sending the handshake request.
  - `handshakeeId` (Query parameter): The user receiving the handshake request.
  - `jwt` (Query parameter): JWT token for authentication.
- **Response**:
  - `200 OK`: Returns the newly created handshake object.
  - `400 Bad Request`: If a handshake already exists between the two users.
  - `401 Unauthorized`: If the JWT validation fails.
  - `500 Internal Server Error`: If an unexpected error occurs.

#### 4. `PUT /api/handshakes/updateStatus/{handshakeId}`
- **Description**: Updates the status of a handshake (`ACCEPTED` or `REJECTED`).
- **Input**:
  - `handshakeId` (Path parameter): The ID of the handshake.
  - `newStatus` (Query parameter): The new status (`ACCEPTED` or `REJECTED`).
  - `jwt` (Query parameter): JWT token for authentication.
- **Response**:
  - `200 OK`: Returns the updated handshake object.
  - `400 Bad Request`: If the status is invalid.
  - `500 Internal Server Error`: If an error occurs while updating the handshake.

#### 5. `DELETE /api/handshakes/delete/{handshakeId}`
- **Description**: Deletes a handshake.
- **Input**:
  - `handshakeId` (Path parameter): The ID of the handshake to delete.
  - `jwt` (Query parameter): JWT token for authentication.
- **Response**:
  - `200 OK`: Returns the deleted handshake object.
  - `404 Not Found`: If no handshake exists for the given ID.
  - `401 Unauthorized`: If the JWT validation fails.

#### 6. `GET /api/handshakes/isHandShaked`
- **Description**: Checks if two users have an existing handshake.
- **Input**:
  - `user1Id` (Query parameter): ID of the first user.
  - `user2Id` (Query parameter): ID of the second user.
  - `jwt` (Query parameter): JWT token for authentication.
- **Response**:
  - `200 OK`: If a handshake exists, returns the handshake status and object.
  - `200 OK`: If no handshake exists, returns a message indicating this.
  - `400 Bad Request`: If an error occurs while checking.
  - `401 Unauthorized`: If the JWT validation fails.

### Notes:
- **JWT Authentication**: Each endpoint requires a valid JWT token, which is verified using `jwt:validate`.
- **Database Interaction**: The Ballerina `persist` module is used for database interaction, with some raw SQL queries being executed to fetch handshake data.

