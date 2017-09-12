using TKPappKitchenSink
using Base.Test

# please don't name your package like this :P
@test_throws AssertionError local_test("NonExistentPackage_66a0b5a72a90c23b")
