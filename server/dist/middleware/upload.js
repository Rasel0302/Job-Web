import multer from 'multer';
const storage = multer.memoryStorage();
const fileFilter = (req, file, cb) => {
    // Check if file is an image
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    }
    else {
        cb(new Error('Only image files are allowed!'));
    }
};
const upload = multer({
    storage,
    fileFilter,
    limits: {
        fileSize: 5 * 1024 * 1024, // 5MB limit
    },
});
export const uploadSingle = upload.single('profilePhoto');
export const uploadCompanyLogo = upload.single('companyLogo');
