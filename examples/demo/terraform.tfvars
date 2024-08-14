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
  { "name" : "apibankingno",
    "rbac" : [
      {
        "role" : "Developer",
        "members" : ["test"]
      },
      {
        "role" : "Owner",
        "members" : ["test"]
      },
    ],
    "organization_name" : "Dev",
  },
  { "name" : "apibanking2",
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
    "organization_name" : "Test Zone",
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

nexusiq_url      = "http://localhost:8070"
nexusiq_username = "admin"
nexusiq_password = "admin123"