Openedx settings plugin for `Tutor <https://docs.tutor.overhang.io>`_
===================================================================

This is a plugin for `Tutor <https://docs.tutor.overhang.io>`

Installation
------------

The plugin is currently bundled with the `binary releases of Tutor <https://github.com/overhangio/tutor/releases>`_. If you have installed Tutor from source, you will have to install this plugin from source, too::
  
    pip install -e .

Then, to enable this plugin, run::
  
    tutor plugins enable openedx_settings

		
Configuration
-------------

- ``OPENEDX_SETTINGS_LMS`` (default: ``{}``)
- ``OPENEDX_SETTINGS_CMS`` (default: ``{}``)

These values can be modified with ``tutor config save --set PARAM_NAME=VALUE`` commands.