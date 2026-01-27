extends Node

## Test Runner Scene
## Runs all test suites and reports results
## Based on Starbuster's test_runner_scene.gd pattern

const test_suites: Array[PackedScene] = [
	# for each test suite, add its scene here
	# preload('res://tests/systems/game_singleton_test.tscn'),
]

# Specified test suites for development
# Format:
#   - "test_suite_name" - runs all tests in that suite
#   - "test_suite_name:test_method_name" - runs only that specific test method
#
# IMPORTANT: This array MUST be empty for production.
var specified: Array[String] = []

# Tracking variables
var suites_run: int = 0
var total_tests_passed: int = 0
var total_tests_failed: int = 0
var suites_with_failures: int = 0
var total_assertions_passed: int = 0
var total_assertions_failed: int = 0
var failed_test_names: Array[String] = []


func _ready() -> void:
	# Add all --run-test CLI argument values to specified array
	var run_tests: Array[String] = _get_run_test_argument_values()
	if run_tests.size() > 0:
		print("\n\n=== RUNNING TESTS SPECIFIED VIA --run-test ARGUMENT ===")
		specified.clear()
		for t in run_tests:
			specified.append(t)

	# Check for --run-all-tests CLI argument
	if _has_require_all_tests_run_flag():
		if not specified.is_empty():
			print("\n\n=== ERROR: --run-all-tests flag is set but 'specified' array is not empty ===")
			print("The following entries must be removed from the 'specified' array:")
			for entry in specified:
				print("  - %s" % entry)
			print("===================================\n")
			_quit_with_code(1)
			return

	var tests_to_run: Array[Dictionary] = _get_filtered_tests()

	if tests_to_run.is_empty():
		print("\n\nNO TESTS TO RUN\n\n")
		_quit_with_code(0)
		return

	for test_info in tests_to_run:
		await _run_test_scene(test_info["scene"], test_info.get("specific_test", ""))
		await _delay(0.5)

	if total_tests_failed > 0:
		print("\n\n%d FAILURE%s IN %d TEST%s (%d assertions passed, %d assertions failed)\n\n" % [
			total_tests_failed, 
			"S" if total_tests_failed > 1 else "", 
			suites_with_failures, 
			"S" if suites_with_failures > 1 else "", 
			total_assertions_passed, 
			total_assertions_failed
		])
		for failed_test in failed_test_names:
			print(failed_test)
		print("\n")
		_quit_with_code(1)
	else:
		print("\n\n%d TEST%s PASSED IN %d SUITE%s (%d assertions passed)\n\n" % [
			total_tests_passed, 
			"S" if total_tests_passed != 1 else "", 
			suites_run, 
			"S" if suites_run != 1 else "", 
			total_assertions_passed
		])
		_quit_with_code(0)


func _delay(seconds: float) -> Signal:
	var tree: SceneTree = get_tree()
	if not tree:
		return Signal()
	return tree.create_timer(seconds, false).timeout


func _has_require_all_tests_run_flag() -> bool:
	var args: Array = OS.get_cmdline_args()
	for arg in args:
		if arg == "--run-all-tests":
			return true
	return false


func _get_run_test_argument_values() -> Array[String]:
	var values: Array[String] = []
	var args: Array = OS.get_cmdline_args()
	for i in range(args.size()):
		if args[i] == "--run-test" and i + 1 < args.size():
			values.append(args[i + 1])
	return values


func _get_filtered_tests() -> Array[Dictionary]:
	var filtered: Array[Dictionary] = []

	if specified.is_empty():
		for test_scene in test_suites:
			filtered.append({"scene": test_scene, "specific_test": ""})
		return filtered

	print("\n\n=== RUNNING SPECIFIED TESTS ONLY ===")
	for spec in specified:
		var parts: PackedStringArray = spec.split(":", false, 1)
		var test_suite_name: String = parts[0]
		var specific_test: String = parts[1] if parts.size() > 1 else ""

		for test_suite in test_suites:
			var suite_name: String = _get_scene_name(test_suite)
			if suite_name == test_suite_name:
				filtered.append({"scene": test_suite, "specific_test": specific_test})
				if specific_test:
					print("  - %s:%s" % [test_suite_name, specific_test])
				else:
					print("  - %s (all tests)" % test_suite_name)
				break

	print("===================================\n")
	return filtered


func _get_scene_name(scene: PackedScene) -> String:
	var name_parts: PackedStringArray = scene.get_path().split("/")
	return name_parts[name_parts.size() - 1].replace(".tscn", "")


func _run_test_scene(test_scene: PackedScene, specific_test: String = "") -> Signal:
	var name_parts: PackedStringArray = test_scene.get_path().split("/")
	var scene_name: String = name_parts[name_parts.size() - 1].replace(".tscn", "")
	var test_instance: Node = test_scene.instantiate()
	add_child(test_instance)

	if test_instance.has_method("run_all_tests"):
		if specific_test:
			print("\n\n\n--=[ BEGIN %s:%s ]=--" % [scene_name, specific_test])
			await test_instance.run_specific_test(specific_test)
		else:
			print("\n\n\n--=[ BEGIN %s ]=--" % scene_name)
			await test_instance.run_all_tests()

		if test_instance.failures > 0:
			total_tests_failed += test_instance.failures
			suites_with_failures += 1
			for failed_method in test_instance.failed_test_methods:
				failed_test_names.append("%s:%s" % [scene_name, failed_method])
			if specific_test:
				print("\n--=[ %d FAILURE%s in %s:%s (%d assertions passed, %d assertions failed) ]=--" % [
					test_instance.failures, 
					"S" if test_instance.failures > 1 else "", 
					scene_name, 
					specific_test, 
					test_instance.assertions_passed, 
					test_instance.assertions_failed
				])
			else:
				print("\n--=[ %d FAILURE%s in %s (%d assertions passed, %d assertions failed) ]=--" % [
					test_instance.failures, 
					"S" if test_instance.failures > 1 else "", 
					scene_name, 
					test_instance.assertions_passed, 
					test_instance.assertions_failed
				])
		else:
			if specific_test:
				print("\n--=[ PASSED %s:%s (%d assertions passed) ]=-- " % [scene_name, specific_test, test_instance.assertions_passed])
			else:
				print("\n--=[ PASSED %s (%d assertions passed) ]=-- " % [scene_name, test_instance.assertions_passed])

		var tests_passed_in_suite: int = test_instance.tests_run - test_instance.failures
		total_tests_passed += tests_passed_in_suite
		total_assertions_passed += test_instance.assertions_passed
		total_assertions_failed += test_instance.assertions_failed
		suites_run += 1
	else:
		print("\n--=[ %s ]=-- ERROR: %s" % [str(test_scene), "does not have a run_all_tests() method."])
		total_tests_failed += 1
		suites_with_failures += 1

	test_instance.queue_free()
	print("\n\n")
	return _delay(0.1)


func _quit_with_code(code: int) -> void:
	await _delay(0.2)
	get_tree().quit(code)
