class_name TestSuite
extends Node

## TestSuite - Base class for all test suites
## Based on the Starbuster test framework pattern
##
## Each test file extends TestSuite
## - Any method with a name beginning in test_ is a test
## - before_all runs once before all tests
## - before_each runs before each test
## - after_all runs after all tests
## - after_each runs after each test

# Store any failures that occur during testing
var failures: int = 0
# Store the total number of tests run in this suite
var tests_run: int = 0
# Store the total number of assertions that passed
var assertions_passed: int = 0
# Store the total number of assertions that failed
var assertions_failed: int = 0
# Store the names of test methods that had failures
var failed_test_methods: Array[String] = []
# Track the current test method being executed
var current_test_method: String = ""


# Get the name of this test suite
func get_suite_name() -> String:
	var name_parts: PackedStringArray = get_scene_file_path().split("/")
	return name_parts[name_parts.size() - 1].replace(".tscn", "")


# Run all tests in this test suite automatically by discovering test methods
func run_all_tests() -> Signal:
	var test_methods: Array[String] = []

	# Get all methods from this instance
	for method_dict in get_method_list():
		var method_name: String = method_dict["name"]
		# Check if the method name starts with "test_"
		if method_name.begins_with("test_"):
			test_methods.append(method_name)

	# Run before_all if it exists
	if has_method("before_all"):
		await call("before_all")

	# Run each test with before_each and after_each hooks
	for test_method_name in test_methods:
		tests_run += 1
		_begin(test_method_name)

		# Run before_each if it exists
		if has_method("before_each"):
			await call("before_each")

		# Run the actual test with error detection
		var assertions_before: int = assertions_passed + assertions_failed
		if not has_method(test_method_name):
			_fail("Test method '%s' does not exist" % test_method_name)
		else:
			await call(test_method_name)
			# If test completed without any assertions, it might have silently failed
			var assertions_after: int = assertions_passed + assertions_failed
			if assertions_after == assertions_before:
				_fail("Test '%s' completed without any assertions (possible unhandled error)" % test_method_name)

		# Run after_each if it exists
		if has_method("after_each"):
			await call("after_each")

	# Run after_all if it exists
	if has_method("after_all"):
		await call("after_all")

	return _delay(0)


# Run a specific test method by name
func run_specific_test(test_method_name: String) -> Signal:

	if not test_method_name.begins_with("test_"):
		_fail("Invalid test method name: %s (must start with 'test_')" % test_method_name)
		return _delay(0)

	if not has_method(test_method_name):
		_fail("Test method not found: %s" % test_method_name)
		return _delay(0)

	# Run before_all if it exists
	if has_method("before_all"):
		await call("before_all")

	tests_run += 1
	_begin(test_method_name)

	# Run before_each if it exists
	if has_method("before_each"):
		await call("before_each")

	# Run the specific test
	var assertions_before: int = assertions_passed + assertions_failed
	await call(test_method_name)
	var assertions_after: int = assertions_passed + assertions_failed
	if assertions_after == assertions_before:
		_fail("Test '%s' completed without any assertions" % test_method_name)

	# Run after_each if it exists
	if has_method("after_each"):
		await call("after_each")

	# Run after_all if it exists
	if has_method("after_all"):
		await call("after_all")

	return _delay(0)


# Begin the test
func _begin(test_method_name: String) -> void:
	current_test_method = test_method_name
	print("\n\n*\n*  %s\n*" % test_method_name)


# Describe a test with a message
func _note(message: String) -> void:
	print("*  %s\n*" % message)


# Helper delay function
func _delay(seconds: float) -> Signal:
	var tree: SceneTree = get_tree()
	if not tree:
		# Return a signal that never emits if tree unavailable
		return Signal()
	return tree.create_timer(seconds, false).timeout


# Assert that a condition is true
func assert_true(condition: bool, message: String) -> bool:
	if condition:
		return _pass("%s is true" % message)
	else:
		return _fail("Expected %s to be true, but was false" % message)


# Assert that a condition is false
func assert_false(condition: bool, message: String) -> bool:
	if not condition:
		return _pass("%s is false" % message)
	else:
		return _fail("Expected %s to be false, but was true" % message)


# Assert that two values are equal
func assert_eq(actual, expected, message: String) -> bool:
	if actual == expected:
		return _pass("%s %s is equal to %s" % [message, str(actual), str(expected)])
	else:
		return _fail("Expected %s to be %s, but found %s" % [message, str(expected), str(actual)])


# Assert that two values are not equal
func assert_ne(actual, expected, message: String) -> bool:
	if actual != expected:
		return _pass("%s %s is not equal to %s" % [message, str(actual), str(expected)])
	else:
		return _fail("Expected %s to be not equal to %s" % [message, str(expected), str(actual)])


# Assert that two values are approximately equal
func assert_near(actual: float, expected: float, tolerance: float, message: String) -> bool:
	if abs(actual - expected) <= tolerance:
		return _pass("%s %f is near %f (+/-%f)" % [message, actual, expected, tolerance])
	else:
		return _fail("Expected %s to be near %f (+/-%f), but found %f" % [message, expected, tolerance, actual])


# Assert that a value is greater than expected
func assert_gt(actual: float, expected: float, message: String) -> bool:
	if actual > expected:
		return _pass("%s %f is greater than %f" % [message, actual, expected])
	else:
		return _fail("Expected greater than %f (%s), but found %f" % [expected, message, actual])


# Assert that a value is less than expected
func assert_lt(actual: float, expected: float, message: String) -> bool:
	if actual < expected:
		return _pass("%s %f is less than %f" % [message, actual, expected])
	else:
		return _fail("Expected less than %f (%s), but found %f" % [expected, message, actual])


# Assert that a value is greater than or equal to expected
func assert_ge(actual: float, expected: float, message: String) -> bool:
	if actual >= expected:
		return _pass("%s %f is at least %f" % [message, actual, expected])
	else:
		return _fail("Expected at least %f (%s), but found only %f" % [expected, message, actual])


# Assert that a value is less than or equal to expected
func assert_le(actual: float, expected: float, message: String) -> bool:
	if actual <= expected:
		return _pass("%s %f is at most %f" % [message, actual, expected])
	else:
		return _fail("Expected at most %f (%s), but found %f" % [expected, message, actual])


# Assert that a value is null
func assert_null(value, message: String) -> bool:
	if value == null:
		return _pass("%s is null" % message)
	else:
		return _fail("Expected %s to be null, but was not null" % message)


# Assert that a value is not null
func assert_not_null(value, message: String) -> bool:
	if value != null:
		return _pass("%s is not null" % message)
	else:
		return _fail("Expected %s to be not null, but was null" % message)


# Record a success message - returns true
func _pass(message: String) -> bool:
	print("* (OK) %s" % message)
	assertions_passed += 1
	return true


# Record a failure message - returns false
func _fail(message: String) -> bool:
	print("* (FAIL) %s" % message)
	failures += 1
	assertions_failed += 1
	# Track which test method failed
	if current_test_method != "" and not failed_test_methods.has(current_test_method):
		failed_test_methods.append(current_test_method)
	return false
