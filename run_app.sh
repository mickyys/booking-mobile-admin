#!/bin/bash

# Configuration Variables
AUTH0_DOMAIN="auth.reservaloya.cl"
AUTH0_CLIENT_ID="gSv4eupv6F0eRjctmIKrCNzK7Z535Xp9"
AUTH0_AUDIENCE="https://dev-8obo6dl4.us.auth0.com/api/v2/"

echo "Running ReservaloYA Admin with environment variables..."
echo "Domain: $AUTH0_DOMAIN"
echo "Audience: $AUTH0_AUDIENCE"

flutter run \
  --dart-define=AUTH0_DOMAIN=$AUTH0_DOMAIN \
  --dart-define=AUTH0_CLIENT_ID=$AUTH0_CLIENT_ID \
  --dart-define=AUTH0_AUDIENCE=$AUTH0_AUDIENCE \
  --android-project-arg=-PAUTH0_DOMAIN=$AUTH0_DOMAIN
