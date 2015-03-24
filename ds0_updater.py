#!/usr/bin/env python
### Script provided by DataStax.

import ds0_utils
import logger
import conf

# Update the AMI codebase if it's its first boot
if not conf.get_config("AMI", "CompletedFirstBoot"):
    # check if a specific commit was requested
    force_commit = ds0_utils.required_commit()

    # update the repo
    logger.exe('git pull')

    # ensure any AWS removed repo keys will be put back, if removed on bake
    logger.exe('git reset --hard')

    # force a commit, if requested
    if force_commit:
        logger.exe('git reset --hard %s' % force_commit)

# Start AMI start code
try:
    import ds1_launcher
    ds1_launcher.run()
except:
    logger.exception('ds0_updater.py')
