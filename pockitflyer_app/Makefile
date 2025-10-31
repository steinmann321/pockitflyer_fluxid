.PHONY: help maestro maestro-flow maestro-continuous maestro-ios maestro-android maestro-clean maestro-list e2e e2e-watch

help:
	@echo "Maestro E2E Test Commands:"
	@echo "  make maestro              - Run all Maestro tests"
	@echo "  make maestro-flow FLOW=<name> - Run specific flow"
	@echo "  make maestro-continuous   - Run in continuous mode"
	@echo "  make maestro-ios          - Build iOS and run tests"
	@echo "  make maestro-android      - Build Android and run tests"
	@echo "  make maestro-clean        - Clean test reports"
	@echo "  make maestro-list         - List available flows"
	@echo ""
	@echo "Aliases:"
	@echo "  make e2e                  - Alias for 'make maestro'"
	@echo "  make e2e-watch            - Alias for 'make maestro-continuous'"

maestro:
	./maestro/run_tests.sh

e2e: maestro

maestro-flow:
	@if [ -z "$(FLOW)" ]; then \
		echo "Error: FLOW variable is required. Usage: make maestro-flow FLOW=app_launch"; \
		exit 1; \
	fi
	./maestro/run_tests.sh -f $(FLOW)

maestro-continuous:
	./maestro/run_tests.sh -c

e2e-watch: maestro-continuous

maestro-ios:
	./maestro/run_tests.sh -b -p ios

maestro-android:
	./maestro/run_tests.sh -b -p android

maestro-clean:
	rm -rf maestro-reports/
	@echo "Cleaned maestro reports"

maestro-list:
	@ls -1 maestro/flows/*.yaml 2>/dev/null | xargs -n 1 basename || echo "No flows found"
