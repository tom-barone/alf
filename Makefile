# Makefile so I don't have to remember all the docker commands.
#
# Start the container with `make build && make start`.
#   - Alf is compiled as part of the docker build and should be ready to run.
# Jump inside the container with `make shell`.
# Run alf with `make run`.
#
# Experiments:
#
# Force the container to run out of memory and observe the oom-killer logs:
#   1. Set CONTAINER_MEMORY to 128MB
#   2. `make start`
#   (in one terminal)              |   (in another terminal)
#   3. `make shell`                |   5. `make shell`
#   4. `make watch-system-logs`    |   6. `make stress-memory`
#   7. Observe the logs
# Change '--vm-bytes' in the 'stress-memory' target below to experiment
#
# Run alf with restricted container memory and observe the oom-killer logs:
#   1. Set CONTAINER_MEMORY to 128MB
#   2. `make start`
#   (in one terminal)              |   (in another terminal)
#   3. `make shell`                |   5. `make shell`
#   4. `make watch-system-logs`    |   6. `make run`
#   7. Observe the logs
#
# Run alf with heaps of memory and it should complete sucessfully:
#   1. Set CONTAINER_MEMORY to 2GB
#   2. `make start`
#   (in one terminal)              |   (in another terminal)
#   3. `make shell`                |   5. `make shell`
#   4. `make watch-system-logs`    |   6. `make run`
#   7. Observe the logs

CONTAINER_MEMORY=128m # megabytes
#CONTAINER_MEMORY=2g # gigabytes
CONTAINER_CPUS=2 # cores

build:
	docker build -t alf .

# We mount the directories ./infiles and ./indata as volumes when running the container
# They aren't included in the docker image itself during build because they're too big.
start:
	$(MAKE) stop
	docker run -it --detach \
		--privileged \
		--name alf \
		--cpus ${CONTAINER_CPUS} \
		--volume ./infiles/:/alf/infiles \
		--volume ./indata/:/alf/indata \
		--memory ${CONTAINER_MEMORY} \
		alf:latest

stop:
	docker stop alf -s 9 | xargs docker rm -f || true

shell:
	docker exec -it alf bash

clean:
	rm -rf src/*.o src/*.mod bin/*.exe

# [https://manpages.debian.org/testing/stress/stress.1.en.html]
stress-cpu:
	stress --cpu 2 --timeout 10

# [https://manpages.debian.org/testing/stress/stress.1.en.html]
stress-memory:
	stress --vm 1 --vm-bytes 300M --timeout 10

# `dmesg` only works if the container is run with `--privileged`
watch-system-logs:
	dmesg -w

run:
	cd subjobs && mpirun -n 1 ../bin/alf.exe sdss_vbin200
