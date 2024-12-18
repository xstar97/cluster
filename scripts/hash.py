import os
import hashlib
import base64
import argparse

# Constant-time comparison to prevent timing attacks (like in the C++ implementation)
def slow_equals(a, b):
    if len(a) != len(b):
        return False
    diff = 0
    for x, y in zip(a, b):
        diff |= x ^ y
    return diff == 0

# PBKDF2 hashing function using HMAC-SHA512
def generate_pbkdf2_hash(password, iterations=100000, dklen=64):
    # Generate a random 16-byte salt (matching the C++ 4 * uint32_t = 16 bytes)
    salt = os.urandom(16)
    
    # Derive the key using PBKDF2 with HMAC-SHA512
    dk = hashlib.pbkdf2_hmac('sha512', password.encode(), salt, iterations, dklen)
    
    # Base64-encode the salt and derived key
    salt_b64 = base64.b64encode(salt).decode('utf-8')
    dk_b64 = base64.b64encode(dk).decode('utf-8')
    
    # Return the formatted hash in the @ByteArray format
    return f"@ByteArray({salt_b64}:{dk_b64})"

# Verify a password against a stored PBKDF2 hash
def verify_pbkdf2_hash(stored_hash, password):
    # Split the stored hash into salt and key parts
    salt_b64, key_b64 = stored_hash.split(":")
    
    # Decode the salt and key from Base64
    salt = base64.b64decode(salt_b64)
    stored_key = base64.b64decode(key_b64)
    
    # Derive the key using PBKDF2 with HMAC-SHA512
    dk = hashlib.pbkdf2_hmac('sha512', password.encode(), salt, 100000, len(stored_key))
    
    # Compare the derived key with the stored key using constant-time comparison
    return slow_equals(stored_key, dk)

# Main function to handle command-line arguments
def main():
    # Create argument parser
    parser = argparse.ArgumentParser(description="PBKDF2 Hash Generator and Verifier")
    
    # Add --password argument
    parser.add_argument('--password', required=True, help="Password to hash or verify")
    
    # Parse arguments
    args = parser.parse_args()
    
    password = args.password
    
    # Generate the PBKDF2 hash for the password
    pbkdf2_hash = generate_pbkdf2_hash(password)
    print("Generated PBKDF2 Hash:")
    print(pbkdf2_hash)

    # Optionally, you can verify the password if you have a stored hash:
    # is_valid = verify_pbkdf2_hash(pbkdf2_hash, password)
    # print("Password verification:", "Success" if is_valid else "Failure")

if __name__ == "__main__":
    main()
