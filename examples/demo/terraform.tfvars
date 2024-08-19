organizations = [
  {
    "name" : "Test Zone",
    "rbac" : [],
    "sourcecontrol" : {
      "provider" : "github",
      "repository" : "",
    },
  },
  {
    "name" : "Dev",
    "rbac" : [
      {
        "role" : "Owner",
        "members" : ["test"]
      },
    ],
  },
  {
    "name" : "Another Sanbox",
    "rbac" : [
      {
        "role" : "Developer",
        "members" : ["test"]
      },
      {
        "role" : "Owner",
        "members" : ["apiuser"]
      },
    ],
  },
]

applications = [
  { "name" : "Web",
    "rbac" : [
      {
        "role" : "Developer",
        "members" : ["test"]
      },
      {
        "role" : "Owner",
        "members" : ["apiuser"]
      },
    ],

  },
  { "name" : "Blog",
    "rbac" : [
      {
        "role" : "Developer",
        "members" : ["test", "apiuser"]
      },
      {
        "role" : "Owner",
        "members" : ["test"]
      },
    ],

  },
]

users = [
  {
    "username" : "test",
    "password" : "test",
    "email" : "test1",
  },
  {
    "username" : "apiuser",
    "password" : "apiuser",
    "email" : "test",
  }
]

nexusiq_url      = "http://127.1:8070"
nexusiq_username = "admin"
nexusiq_password = "admin123"