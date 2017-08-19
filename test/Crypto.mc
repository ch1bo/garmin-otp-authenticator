// Test that SHA1 works using some sample invocations
(:test)
function hashSHA1_test1(logger) {
  return hashSHA1("abcdefghijkl") == "fe764d301d0e321c237d739843ebcfa6e002328e";
}
