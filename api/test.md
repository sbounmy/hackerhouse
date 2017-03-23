curl -X POST https://connect.stripe.com/oauth/token \
-d client_secret=sk_test_9uop1mz9UF4RgRz9XWDQKAII \
-d code=ac_9a2U4Oeu58815wikYqjIqOdAGHVAUXCj \
-d grant_type=authorization_code

curl -X POST https://connect.stripe.com/oauth/token \
-d client_secret=sk_live_k5RkrxXfnei7cLBryih8ui85 \
-d code=ac_9aRV5XQmwATovvFpTmsSkCdkOcPVihup \
-d grant_type=authorization_code

// Ivry live
curl -X POST https://connect.stripe.com/oauth/token \
-d client_secret=sk_live_k5RkrxXfnei7cLBryih8ui85 \
-d code=ac_9aRcN5Nw4c5IqTMIVSPtNPtl6PuewPIP \
-d grant_type=authorization_code

// Canal Street TEST
curl -X POST https://connect.stripe.com/oauth/token \
-d client_secret=sk_test_9uop1mz9UF4RgRz9XWDQKAII \
-d code=ac_9afguyMTYMHd5TBk5G2yfjSPn3GlLlc0 \
-d grant_type=authorization_code
{
  "access_token": "sk_test_CdErq6l3Sw77QoDDzg7N4yxx",
  "livemode": false,
  "refresh_token": "rt_9afkHmJVl7JYwdKuFyWy4L8aXjLpLP1Zp6pToTMYrcrfcAUi",
  "token_type": "bearer",
  "stripe_publishable_key": "pk_test_yM7BRpCKOikhr3cgsBhZH50f",
  "stripe_user_id": "acct_196ilqDYc3Fsxkp3",
  "scope": "read_write"
}

// Canal Street Live
curl -X POST https://connect.stripe.com/oauth/token \
-d client_secret=sk_live_k5RkrxXfnei7cLBryih8ui85 \
-d code=ac_9afnS9EZaCxzFuKpNbdMG7RrKE7TPY9v \
-d grant_type=authorization_code
{
  "access_token": "sk_live_M5UH2JcMxW8zvtoFq7Bunm99",
  "livemode": true,
  "refresh_token": "rt_9afqv9YIcdV7dDG1OglkgSaFfRPodXyGJuF0Q3B4ZrNAXNc7",
  "token_type": "bearer",
  "stripe_publishable_key": "pk_live_j8MFifzzbbZWr4huzMV2rAeY",
  "stripe_user_id": "acct_196ilqDYc3Fsxkp3",
  "scope": "read_write"
}