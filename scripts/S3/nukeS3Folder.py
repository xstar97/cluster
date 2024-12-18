import boto3
from botocore.exceptions import ClientError
import logging
import yaml

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Path to the YAML configuration file
CONFIG_PATH = "/home/xstar97/Desktop/cluster/clusters/main/clusterenv.yaml"

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
    s3 = boto3.resource(
        's3',
        endpoint_url=endpoint_url,
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key
    )

    bucket = s3.Bucket(bucket_name)
    dirs = set()

    try:
        for obj in bucket.objects.all():
            key = obj.key
            if "/" in key:  # Filter keys with subdirectories
                first_level_dir = key.split("/", 1)[0]
                dirs.add(first_level_dir)
    except ClientError as e:
        logger.error("Error fetching objects from bucket '%s': %s", bucket_name, e)
        raise
    return sorted(dirs)

def delete_folder(endpoint_url, access_key, secret_key, bucket_name, folder_name):
    """
    Deletes a folder and its contents from an R2 bucket.

    :param endpoint_url: S3-compatible endpoint URL.
    :param access_key: Access key for authentication.
    :param secret_key: Secret key for authentication.
    :param bucket_name: Name of the R2 bucket.
    :param folder_name: Name of the folder to delete.
    """
    s3 = boto3.client(
        's3',
        endpoint_url=endpoint_url,
        aws_access_key_id=access_key,
        aws_secret_access_key=secret_key
    )

    try:
        response = s3.list_objects_v2(Bucket=bucket_name, Prefix=f"{folder_name}/")
        if "Contents" in response:
            objects_to_delete = [{"Key": obj["Key"]} for obj in response["Contents"]]
            s3.delete_objects(Bucket=bucket_name, Delete={"Objects": objects_to_delete})
            logger.info("Folder '%s' and its contents have been deleted.", folder_name)
        else:
            logger.info("Folder '%s' does not exist or is already empty.", folder_name)
    except ClientError as e:
        logger.error("Failed to delete folder '%s': %s", folder_name, e)
        raise

def validate_and_prompt_deletion(dirs, folder_name, endpoint_url, access_key, secret_key, bucket_name):
    """
    Validates if a folder exists and prompts the user to delete it.

    :param dirs: List of first-level directories.
    :param folder_name: Name of the folder to validate.
    :param endpoint_url: S3-compatible endpoint URL.
    :param access_key: Access key for authentication.
    :param secret_key: Secret key for authentication.
    :param bucket_name: Name of the R2 bucket.
    """
    if folder_name in dirs:
        choice = input(f"Folder '{folder_name}' exists. Do you want to delete it? (y/n): ").lower()
        if choice == 'y':
            # logger.info("Deletion completed.")
            delete_folder(endpoint_url, access_key, secret_key, bucket_name, folder_name)
        else:
            logger.info("Deletion canceled.")
    else:
        logger.info("Folder '%s' does not exist.", folder_name)

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
        print("Available folders:", ", ".join(first_level_dirs))

        # Specify the folder (chart) to validate
        chart = input("Enter the name of the folder (chart) to validate: ").strip()
        validate_and_prompt_deletion(first_level_dirs, chart, endpoint_url, access_key, secret_key, bucket_name)
    except Exception as e:
        logger.error("An error occurred: %s", e)
