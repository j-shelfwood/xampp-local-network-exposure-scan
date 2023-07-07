# XAMPP Exposure Scan

This Bash script performs a local network scan to identify XAMPP installations that are exposed on the network. It checks if port 80 is open on each IP address and verifies if the server running at that IP address is XAMPP (or another Apache server).

## Prerequisites

- Bash (GNU Bash 4.0 or later)
- `gtimeout` command (available on macOS using coreutils)
- `nc` (netcat) command
- `curl` command

## Usage

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/xampp-exposure-scan.git
   ```

````

2. Navigate to the project directory:

   ```bash
   cd xampp-exposure-scan
   ```

3. Make the scripts executable:

   ```bash
   chmod +x scan.sh check_ip.sh
   ```

4. Run the scan:

   ```bash
   ./scan.sh
   ```

   The script will scan the local network for IP addresses, check their exposure, and display the results. It will also provide an overview table of the IP addresses and their statuses.

   You can use the `--test` flag to test a specific IP address, and the `--verbose` flag to display more verbose information about the response.

   ```bash
   # Test a specific IP address with verbose output
   ./scan.sh --test --verbose

   # Test a specific IP address without verbose output
   ./scan.sh --test
   ```

## Output

The script will display the progress of the scan, individual IP address checks, and an overview table with clickable links to open the identified IP addresses in a default browser.

## Contributing

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE).
````
