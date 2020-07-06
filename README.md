# Mobile Foundation Cloud deployer CLI

A command-line utility for automating the Mobile Foundation(MF) deployment on RedHat OpenShift Cluster. This utility supports deployments for Linux and Mac OSX.

Created using the CASE pkg published [here](https://github.com/IBM/cloud-pak/tree/master/repo/case/ibm-mobilefoundation/8.1.0)

## Prerequisites

- RedHat® OpenShift Cluster 4.3.0+ (with *Administrator* privileges).
- [OpenShift client tools](https://docs.openshift.com/container-platform/3.11/cli_reference/get_started_cli.html) (if the cluster administrator has enabled it, you can download and unpack the CLI from the **About page** on the OpenShift web console).
- Docker® client (19.03.8+).
- `jq` utility ([install documentation](https://github.com/stedolan/jq/wiki/Installation)) *- usually pre-installed on Linux and MacOSX machines.*

## Cluster requirements

For deploying server with two replica-sets with Push Notifications enabled
minimum **1 worker with node 8Gi memory** and **8Cores** is required.

Note: Cluster capacity will increase when the number of replica-set (pods) are increased or on enabling more Mobile Foundation components.

## Installation

1. Clone the repo using the following command.
   
   ```
   git clone git@github.ibm.com:krckumar/mobilefoundation-deployer.git
   cd mobilefoundation-deployer
   ```

2. Login into the OpenShift cluster from Terminal.
3. Set the following environment variables (for external image registry like ER only)

	```
	export DOCKER_REGISTRY=<docker-registry>
	export DOCKER_REGISTRY_USER=<docker-registry-user>
	export DOCKER_REGISTRY_PASSWORD=<docker-registry-password-or-key>
	```
	**Example**: *For Entitled Registry, the commands look as follows.*

	```
	export DOCKER_REGISTRY=cp.icr.io
	export DOCKER_REGISTRY_USER=iamapikey
	export DOCKER_REGISTRY_PASSWORD=sds2asdkmamwe-qqoapwm22323mfdpeo193m0311
	```
4. To set the configuration for the Mobile Foundation (MF) components, **add the deployment values** in the `deployment_values.json` file.

5. To start the deployment, run the following command.
	
	```
	./install-mf <deployment_values.json>

	Options:

	  <deployment_values.json>     Simple JSON format file with all the deployment config values.
	```
	
	**Example:**

	*To deploy with External Image registry (or Entitled Registry)*
	
	```
	./install-mf deployment_values.json
	```

For using the utility within Continous Delivery and Deployment

Ensure the environment variable `CICD` set to `true`.

```
export CICD=true
```

**IMPORTANT NOTE:**
All the generated yaml's used for the deployment gets stored under a directory `mfdeployer/files/temp-DO_NOT_DELETE`. **This directory shouldn't be deleted** as this is needed for uninstall operations. Once the uninstall is completed, the tool automatically renames this directory to a `temp` directory suffixed with timestamp for audit or for enduser's view.
	
## Uninstallation

To uninstall, run the following command.
	
```
./uninstall-mf deployment_values.json [ <mf_deployed_namespace> ]

Options:
  
  <deployment_values.json>     Simple JSON format file with all the deployment config values.
  <mf-namespace>               [Optional] Project/Namespace under which Mobile Foundation is deployed. 
                               Default current namespace.
```

### Continous Delivery and Deployment
For using the utility within Continous Delivery and Deployment, ensure the environment variable `CICD` set to `true`.

```
export CICD=true
```

### Advanced customization
​
To set the custom TLS secret, truststore, keystore, configuration, etc., you need to have them created before the deployment and set the appropriate deployment values before installation. Following documentation links, provide the steps for the same.
	
- [Creating custom keyStore secret for the deployments](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/ibmcloud/mobilefoundation-on-openshift/additional-docs/cr-configuration/#optional-creating-custom-keystore-secret-for-the-deployments)
- [Using Custom Server Configuration](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/ibmcloud/mobilefoundation-on-openshift/additional-docs/cr-configuration/#optional-custom-server-configuration)
- [Using custom Ingress TLS Secret](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/ibmcloud/mobilefoundation-on-openshift/additional-docs/cr-configuration/#optional-creating-tls-secret-for-ingress-configuration)
	

## Known Limitation(s)

1. This is a command-line utility need `bash` or `sh` shell with `jq` to run. Targetted for Linux/MacOSX Terminals.

However, to workaround follow the below steps.

   - Install `gitbash` or `cygwin`
   - Refer the Stackoverflow article - [How to run jq from gitbash in windows?](https://stackoverflow.com/questions/53967693/how-to-run-jq-from-gitbash-in-windows)

2. Resource/Capacity related incompatibility are not addressed during the input validation

## References

1. [Get started with Mobile Foundation on an OpenShift cluster](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/ibmcloud/getting-started-mf-on-rhos/)
2. [Mobile Foundation on IBM® Cloud RedHat® OpenShift](https://mobilefirstplatform.ibmcloud.com/tutorials/en/foundation/8.0/ibmcloud/deploy-mf-on-ibmcloud-ocp/)
