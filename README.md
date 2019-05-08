# Broadcaster

Broadcaster is a REST API developed in [Vapor](https://vapor.codes), backed by an in-memory SQLite database.

## API Endpoints

### GET /api/ping

Check if the endpoint it alive.

Example response `200 OK`:

```
pong
```

### POST /api/users/login

Authenticate using [HTTP Basic](https://en.wikipedia.org/wiki/Basic_access_authentication) to log in a user. This will return the logged in user, and a token to use in subsequent requests.

Example response:

```json
{
  "id": "BD75BAF2-35DB-43ED-A90F-A934A0FD8D3C",
  "expiresAt": "2019-05-08T09:51:22Z",
  "userID": "41ACB244-D6BC-4F36-8727-E64ECFC7DAF4",
  "token": "1FPiHtwhsh0fo2OZR6UwYg=="
}
```

### GET /api/users (authenticated)

Fetch all registered users.

_Requires Bearer Token based authentication using the token returned by the_ login _endpoint._

Example response:

```json
[
  {
    "id": "797AF435-B2CF-4D9D-9FC3-4898A441147B",
    "name": "Admin",
    "username": "admin"
  },
  {
    "id": "76518DF1-EBCB-47EB-A9BD-DE9393111093",
    "name": "Default user",
    "username": "user"
  }
]
```

### POST /api/instances (authenticated)

Create a new instance.

_Requires Bearer Token based authentication using the token returned by the_ login _endpoint._

Example request body:

```json
{
	"uuid": "f6ae2f02-d7b8-4ff8-9989-70560b3d48e1",
	"version": "MyVersion",
	"name": "InstanceName",
	"track": "TrackName",
	"ip": "10.11.12.13",
	"port": 8080,
	"fullName": "FirstName LastName",
	"userName": "firstname.lastname",
	"location": "UK"
}
```

Example response:

```json
{
  "id": "860D0042-63D9-421B-80CC-02E06E23A4E4",
  "updatedAt": "2019-05-08T10:13:16Z",
  "userID": "797AF435-B2CF-4D9D-9FC3-4898A441147B",
  "digest": "c967e98c7fdbda78019c0685cbe1828f3308497b",
  "version": "MyVersion",
  "userName": "firstname.lastname",
  "location": "UK",
  "fullName": "FirstName LastName",
  "ip": "10.11.12.13",
  "track": "TrackName",
  "expiresAt": "2019-05-08T10:14:16Z",
  "createdAt": "2019-05-08T10:13:16Z",
  "name": "InstanceName",
  "port": 8080
}
```

### GET /api/instances (authenticated)

Get all instances.

_Requires Bearer Token based authentication using the token returned by the_ login _endpoint._

Example response:

```json
[
	{
	  "id": "860D0042-63D9-421B-80CC-02E06E23A4E4",
	  "updatedAt": "2019-05-08T10:13:16Z",
	  "userID": "797AF435-B2CF-4D9D-9FC3-4898A441147B",
	  "digest": "c967e98c7fdbda78019c0685cbe1828f3308497b",
	  "version": "MyVersion",
	  "userName": "firstname.lastname",
	  "location": "UK",
	  "fullName": "FirstName LastName",
	  "ip": "10.11.12.13",
	  "track": "TrackName",
	  "expiresAt": "2019-05-08T10:14:16Z",
	  "createdAt": "2019-05-08T10:13:16Z",
	  "name": "InstanceName",
	  "port": 8080
	}
]
```

### GET /api/instances/search?digest=DIGEST (authenticated)

Search an instance by its SHA1 digest. The digest is a hex encoded SHA1 hash of the concatenation of several instance properties.

```swift
        if let digest = try? SHA1.hash(name + version + track + String(port) + userName + location) {
            self.digest = digest.hexEncodedString()
        }
``` 

_Requires Bearer Token based authentication using the token returned by the_ login _endpoint._

```json
{
  "id": "860D0042-63D9-421B-80CC-02E06E23A4E4",
  "updatedAt": "2019-05-08T10:13:16Z",
  "userID": "797AF435-B2CF-4D9D-9FC3-4898A441147B",
  "digest": "c967e98c7fdbda78019c0685cbe1828f3308497b",
  "version": "MyVersion",
  "userName": "firstname.lastname",
  "location": "UK",
  "fullName": "FirstName LastName",
  "ip": "10.11.12.13",
  "track": "TrackName",
  "expiresAt": "2019-05-08T10:14:16Z",
  "createdAt": "2019-05-08T10:13:16Z",
  "name": "InstanceName",
  "port": 8080
}
```

### PUT /api/instances/INSTANCEID/ping (authenticated)

Keep an instance alive and update its expiry, so it will not be deleted during the cleanup cycle.

_Requires Bearer Token based authentication using the token returned by the_ login _endpoint._

Returns `204 No Content` on success.

### DELETE /api/instances/INSTANCEID (authenticated)

Delete an instance.

_Requires Bearer Token based authentication using the token returned by the_ login _endpoint._

Returns `204 No Content` on success.

## Xcode

Make sure you have installed the [vapor toolchain](https://docs.vapor.codes/3.0/install/macos/), then run the following commands to get started in Xcode:

```bash
git clone https://github.com/4np/Broadcaster.git
cd Broadcaster
vapor xcode -y
```

This will clone the project, create the `xcodeproj` and launch Xcode. Make sure to select `My Mac` as your run destination, then run.

## Linux

While you can run the project easily on [Vapor Cloud](https://vapor.cloud), you can run it on your Linux server using [Supervisor](http://supervisord.org) (on [Ubuntu](https://www.ubuntu.com): `apt-get install supervisor`).

Sample `/etc/supervisor/conf.d/broadcaster.conf` configuration:

```conf
[program:broadcaster]
environment=INSTANCE_LIFETIME=300,CLEANUP_JOB_INTERVAL=60,ADMIN_USER_PASSWORD=somerandompassword,DEFAULT_USER=User,DEFAULT_USER_USERNAME=user,DEFAULT_USER_PASSWORD=somerandompassword
command=/home/vapor/Broadcaster/.build/x86_64-unknown-linux/release/Run serve --env prod
directory=/home/vapor/Broadcaster
user=vapor
autostart=true
autorestart=true
startsecs=5
startretries=3
stdout_logfile=/var/log/supervisor/%(program_name)-stdout.log
stderr_logfile=/var/log/supervisor/%(program_name)-stderr.log
```

_Note: this assumes you have created a `vapor` user, and you have checked out the repository at `/path/to/Broadcaster`. Also make sure to update the environment variables that are used to update the scheduled jobs and seed the default users with._

In order to run, you need to clone the repo to `/home/vapor/Broadcaster`:

```bash
su - vapor
git clone https://github.com/4np/Broadcaster.git
cd Broadcaster
./build-release.sh
```
_Note: this assumes you installed [Swift](https://tecadmin.net/install-swift-ubuntu-1804-bionic/) on your Linux box._

Then (re)start supervisor:

```bash
service supervisor restart
```

You should now have a running API which you can open up through your firewall, or use nginx as a proxy (preferably using letsencrypt certs).

_Note: as this is using an in-memory SQLite database, users, instances and tokens will be cleared between restarts!_

# License

See the accompanying [LICENSE](LICENSE) file for more information.

```
Copyright 2019 Jeroen Wesbeek

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```