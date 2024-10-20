import { useState,useEffect} from "react";

const AboutSection = ({ userData, isOwnProfile, onSave }) => {
	const [isEditing, setIsEditing] = useState(false);
	const [about, setAbout] = useState(userData.about_me || "");
	console.log("About Section", userData);

	const handleSave = () => {
		setIsEditing(false);
		const updatedData = { about_me: about };
		onSave(updatedData);
	};
	return (
		<div className='bg-white shadow rounded-lg p-6 mb-6'>
			<h2 className='text-xl font-semibold mb-4'>About</h2>
			{isOwnProfile!=null && (
				<>
					{isEditing ? (
						<>
							<textarea
								value={about}
								onChange={(e) => setAbout(e.target.value)}
								className='w-full p-2 border rounded'
								rows='4'
							/>
							<button
								onClick={handleSave}
								className='mt-2 bg-primary text-white py-2 px-4 rounded hover:bg-primary-dark 
								transition duration-300'
							>
								Save
							</button>
						</>
					) : (
						<>
							<p>{userData.about_me}</p>
							<button
								onClick={() => setIsEditing(true)}
								className='mt-2 text-primary hover:text-primary-dark transition duration-300'
							>
								Edit
							</button>
						</>
					)}
				</>
			)}
		</div>
	);
};
export default AboutSection;
