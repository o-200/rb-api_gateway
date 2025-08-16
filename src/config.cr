MICROSERVICES = {
  "rb-user" => {
    "domain": "rb-user:3001",
    "paths":  {
      "user": {
        "register":     "auth/register",
        "login":        "auth/login",
        "logout":       "auth/logout",
        "verify":       "auth/verify",
        "refresh":      "auth/refresh",
        "current_user": "auth/current_user",
      },
      "bird": {
        "birds_by_user_id": "birds"
      }
    },
  },
}
