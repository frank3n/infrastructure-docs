When you *add extra storage during the initial VPS order on Hetzner* you got a **Volume** attached to the VPS.

📌 **Volumes ≠ Storage Boxes**

* **Volumes** = block devices attached to your VPS (like plugging in an external SSD).
* **Storage Boxes** = remote network storage via SFTP/WebDAV/SMB.

So your **extra 500 GB** is a **block storage Volume**, and it must be **mounted manually** inside Fedora before it appears.

Let’s locate it.

---

# ✅ **1. Check attached block devices**

Run:

```bash
lsblk -f
```

You will see something like:

```
sda   (your main VPS disk, maybe 40–80 GB)
└─sda1 (root)

sdb   (your 500 GB volume!)
```

If you see `sdb` or `vdb` or similar with **no filesystem**, that is your extra space.

---

# ✅ **2. If you see the new disk, format it**

Assuming it appears as **/dev/sdb**:

```bash
sudo mkfs.ext4 /dev/sdb
```

---

# ✅ **3. Create a mount point**

Example:

```bash
sudo mkdir /mnt/storage
```

---

# ✅ **4. Mount the new 500 GB volume**

```bash
sudo mount /dev/sdb /mnt/storage
```

Now check:

```bash
df -h
```

You should see 500 GB available.

---

# ✅ **5. Make mount permanent (fstab entry)**

Edit:

```bash
sudo nano /etc/fstab
```

Add this line:

```
/dev/sdb /mnt/storage ext4 defaults 0 0
```

Save → exit → reboot.

---

# 🧠 **IMPORTANT CLARIFICATION**

### ✔ If you added “additional disk space” during VPS creation

That is **a Volume**, not a partition on your root disk.

### ✔ Volumes always show up as separate block devices

Typically:

* `/dev/sdb`
* `/dev/vdb`
* `/dev/nvme1n1` (on NVMe nodes)

### ✔ They must be formatted + mounted manually

Otherwise they are invisible.

---

# 🧩 Example lsblk output before mounting:

```
NAME        SIZE TYPE MOUNTPOINT
sda          80G disk
└─sda1       80G part /

sdb         500G disk   ← your added storage
```

If you see no filesystem (`FSTYPE` empty), that’s correct.

---

# ❓ Want me to check your actual output?

If you paste the result of:

```bash
lsblk -f
```

I will tell you exactly:

* which device is your 500 GB volume
* how to format it correctly
* how to mount it permanently

I can also help you set up:

* VHDX → upload → store on `/mnt/storage`
* rclone → sync to Storage Box or Hetzner S3
* backup rotation scripts

Just send the lsblk output.
