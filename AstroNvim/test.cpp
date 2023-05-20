#include <bits/stdc++.h>

using namespace std;

int mod = 1e9 + 7;
int maxn = 1e5 + 5;

int main() {
  int t, k;
  cin >> t >> k;
  vector<int> dp(maxn);
  dp[0] = 1;
  for (int i = 1; i < maxn; ++i) {
    if (i - k >= 0) {
      dp[i] = (dp[i] + dp[i - k]) % mod;
    }
    dp[i] = (dp[i] + dp[i - 1]) % mod;
  }
  for (int i = 1; i < maxn; ++i) {
    dp[i] = (dp[i] + dp[i - 1]) % mod;
  }
  int a, b;
  while (t--) {
    cin >> a >> b;
    int res = dp[b] - dp[a - 1];
    res = (res + mod) % mod;
    cout << res << '\n';
  }
}
