MICROSERVICES = {
  "rb-user" => {
    "domain": "rb-user:3001",
    "paths":  {
      "register": "auth/register",
      "login":    "auth/login",
      "logout":   "auth/logout",
      "verify":   "auth/verify",
      "refresh":  "auth/refresh",
    },
  },
}
