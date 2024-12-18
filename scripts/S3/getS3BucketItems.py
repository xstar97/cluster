import boto3
from botocore.exceptions import ClientError
import logging
import yaml

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Path to the YAML configuration file
CONFIG_PATH = "/home/cluster/clusters/main/clusterenv.yaml"

def load_config(config_path):
    """
    Loads configuration variables from a YAML file.

    :param config_path: Path to the YAML file.
    :return: Dictionary containing configuration variables.
    """
    try:
        with open(config_path, 'r') as file:
            config = yaml.safe_load(file)
        return config
    except Exception as e:
        logger.error("Failed to load configuration from %s: %s", config_path, e)
        raise

def list_first_level_dirs(endpoint_url, access_key, secret_key, bucket_name):
    """
    Lists first-level directories in an R2 bucket.

    :param endpoint_url: S3-compatible endpoint URL.
    :param access_key: Access key for authentication.
    :param secret_key: Secret key for authentication.
    :param bucket_name: Name of the R2 bucket.
    :return: List of first-level directory names.
    """
    # Create the S3 client
    s3 = boto3.resource(
        's3',
        endpoint_url=endpoint_url,
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key
    )

    # Get the bucket
    bucket = s3.Bucket(bucket_name)

    try:
        # Collect keys and extract first-level directories
        dirs = set()
        for obj in bucket.objects.all():
            key = obj.key
            if "/" in key:  # Filter keys with subdirectories
                first_level_dir = key.split("/", 1)[0]
                dirs.add(first_level_dir)
    except ClientError as e:
        logger.error("Error fetching objects from bucket '%s': %s", bucket_name, e)
        raise
    else:
        return sorted(dirs)

def print_comma_separated_list(dirs):
    """
    Prints the list of directories as a comma-separated string.
    
    :param dirs: List of directory names.
    """
    print(",".join(dirs))

if __name__ == "__main__":
    try:
        # Load configuration
        config = load_config(CONFIG_PATH)
        
        # Extract required variables from the configuration
        endpoint_url = config["S3URL_RESTIC"]
        access_key = config["S3ID_RESTIC"]
        secret_key = config["S3KEY_RESTIC"]
        bucket_name = config["S3_BUCKET_RESTIC"]

        # List first-level directories
        first_level_dirs = list_first_level_dirs(endpoint_url, access_key, secret_key, bucket_name)
        print_comma_separated_list(first_level_dirs)
    except Exception as e:
        logger.error("Failed to list directories: %s", e)
