organizations = [
  {
    "name" : "Test",
    "parent_organization_name" : "Root Organization",
    
  },
  {
    "name" : "Sandbox",
    "parent_organization_name" : "Test",
   
  },

]

applications = [
  { "name" : "apibanking",
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
    "organization_name" : "Test",
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
    "organization_name" : "Test",
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
