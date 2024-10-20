import { Briefcase, X } from "lucide-react";
import { useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { formatDate } from "../utils/dateUtils";
import { axiosInstance } from "../lib/axios";

const ExperienceSection = ({ userData, isOwnProfile }) => {
	const [isEditing, setIsEditing] = useState(false);
	const [stories, setStories] = useState([]);
	const [newStory, setNewStory] = useState({
		name: "",
		logoUrl: "",
		startDate: "",
		endDate: "",
		description: "",
		domain: "",
		learning: "",
		success: false,
	});
	const token = localStorage.getItem("jwt");
	const queryClient = useQueryClient();

	const { isLoading, isError } = useQuery({
		queryKey: ['stories', userData],
		queryFn: async () => {
			const response = await axiosInstance.get(`/stories/getstoriesbyuserid/?userId=${userData.id}&jwt=${token}`);
			if (response.status !== 200) {
				throw new Error('Network response was not ok');
			}
			setStories(response.data.stories_records);
			return response.data.stories_records || [];
		},
	});
	const saveStoryMutation = useMutation({
		mutationFn: async (story) => {
			await axiosInstance.post(
				`/stories/add?userId=${userData.id}&jwt=${token}`,
				story
			);
		},
		onSuccess: () => {
			queryClient.invalidateQueries(["stories", userData.id]);
			setIsEditing(false);
		},
	});

	const handleAddStory = () => {
		if (newStory.name && newStory.logoUrl && newStory.startDate) {
			saveStoryMutation.mutate({
				name: newStory.name,
				logo_url: newStory.logoUrl,
				start_date: new Date(newStory.startDate).toISOString(), // Convert to ISO string
			end_date: newStory.endDate ? new Date(newStory.endDate).toISOString() : null, // Convert to ISO string or null
			description: newStory.description,
				domain: newStory.domain,
				learning: newStory.learning,
				success: newStory.success,
			});
			
			setNewStory({
				name: "",
				logoUrl: "",
				startDate: "",
				endDate: "",
				description: "",
				domain: "",
				learning: "",
				success: false,
			});
		}
	};

	const handleDeleteStory = (id) => {
		// Implement delete logic here
	};

	if (isLoading) return <div>Loading...</div>;
	if (isError) return <div>Error fetching stories</div>;

	return (
		<div className='bg-white shadow rounded-lg p-6 mb-6'>
			<h2 className='text-xl font-semibold mb-4'>Stories</h2>
			{stories.map((story) => (
				<div key={story.id} className='mb-4 flex justify-between items-start'>
					<div className='flex items-start'>
						<img src={story.logo_url} alt={story.name} className='mr-2 mt-1 h-10 w-10' />
						<div>
							<h3 className='font-semibold'>{story.name}</h3>
							<p className='text-gray-600'>{story.domain}</p>
							<p className='text-gray-500 text-sm'>
								{formatDate(`${story.start_date.year}-${story.start_date.month}-${story.start_date.day}`)} - 
								{story.end_date ? formatDate(`${story.end_date.year}-${story.end_date.month}-${story.end_date.day}`) : "Present"}
							</p>
							<p className='text-gray-700'>{story.description}</p>
							<p className='text-gray-500'>{story.learning}</p>
							<p className='text-gray-500'>Success: {story.success ? 'Yes' : 'No'}</p>
						</div>
					</div>
					{isEditing && (
						<button onClick={() => handleDeleteStory(story.id)} className='text-red-500'>
							<X size={20} />
						</button>
					)}
				</div>
			))}

			{isEditing && (
				<div className='mt-4'>
					<input
						type='text'
						placeholder='Name'
						value={newStory.name}
						onChange={(e) => setNewStory({ ...newStory, name: e.target.value })}
						className='w-full p-2 border rounded mb-2'
					/>
					<input
						type='text'
						placeholder='Logo URL'
						value={newStory.logoUrl}
						onChange={(e) => setNewStory({ ...newStory, logoUrl: e.target.value })}
						className='w-full p-2 border rounded mb-2'
					/>
					<input
						type='date'
						placeholder='Start Date'
						value={newStory.startDate}
						onChange={(e) => setNewStory({ ...newStory, startDate: e.target.value })}
						className='w-full p-2 border rounded mb-2'
					/>
					<input
						type='date'
						placeholder='End Date'
						value={newStory.endDate}
						onChange={(e) => setNewStory({ ...newStory, endDate: e.target.value })}
						className='w-full p-2 border rounded mb-2'
					/>
					<textarea
						placeholder='Description'
						value={newStory.description}
						onChange={(e) => setNewStory({ ...newStory, description: e.target.value })}
						className='w-full p-2 border rounded mb-2'
					/>
					<input
						type='text'
						placeholder='Domain'
						value={newStory.domain}
						onChange={(e) => setNewStory({ ...newStory, domain: e.target.value })}
						className='w-full p-2 border rounded mb-2'
					/>
					<textarea
						placeholder='Learning'
						value={newStory.learning}
						onChange={(e) => setNewStory({ ...newStory, learning: e.target.value })}
						className='w-full p-2 border rounded mb-2'
					/>
					<label className='flex items-center mb-2'>
						<input
							type='checkbox'
							checked={newStory.success}
							onChange={(e) => setNewStory({ ...newStory, success: e.target.checked })}
						/>
						<span className='ml-2'>Success</span>
					</label>
					<button
						onClick={handleAddStory}
						className='bg-primary text-white py-2 px-4 rounded hover:bg-primary-dark transition duration-300'
					>
						Add Story
					</button>
				</div>
			)}

			{isOwnProfile && (
				<>
					{isEditing ? (
						<button
							onClick={() => setIsEditing(false)} // Implement save logic if needed
							className='mt-4 bg-primary text-white py-2 px-4 rounded hover:bg-primary-dark transition duration-300'
						>
							Save Changes
						</button>
					) : (
						<button
							onClick={() => setIsEditing(true)}
							className='mt-4 text-primary hover:text-primary-dark transition duration-300'
						>
							Edit Stories
						</button>
					)}
				</>
			)}
		</div>
	);
};

export default ExperienceSection;
