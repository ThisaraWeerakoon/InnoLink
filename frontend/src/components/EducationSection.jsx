import { School, X } from "lucide-react";
import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { axiosInstance } from "../lib/axios";
import { set } from "mongoose";
const EducationSection = ({ userData, isOwnProfile, onSave }) => {
	const [isEditing, setIsEditing] = useState(false);
	const [educations, setEducations] = useState([]);
	const [newEducation, setNewEducation] = useState({
		institution: "",
		field_of_study: "",
		start_year: "",
		end_year: "",
		degree: "",
	});
	const queryClient = useQueryClient();

	const token = localStorage.getItem("jwt");
	
	const saveEducationMutation = useMutation({
		mutationFn: async (education) => {
		  await axiosInstance.post(
			`/education/add?userId=${userData.id}&jwt=${token}`,
			education
		  );
		},
		onSuccess: () => {
		  // Invalidate the fetch query to refresh the data
		  queryClient.invalidateQueries(["educationData", userData.id]);
		  setIsEditing(false);
		},
	  });

  // Fetch the education data from the API
  const { data: educationData, isLoading, error } = useQuery({
	queryKey: ["educationData", userData.id],
	queryFn: async () => {
	  const response = await axiosInstance.get(
		`/education/geteducationbyuserid?userId=${userData.id}&jwt=${token}`
	  );
	  return response.data;
	},
	onSuccess: (data) => {
	  setEducations(data.education_records); // Set education records from API response
	},
	enabled: !!userData.id, // Only fetch if userData is available
  });
  useEffect(() => {
	console.log("Fetched education data:", educationData); // Log the fetched data
	setEducations(educationData?.education_records); // Set educations from the fetched data
 }, [educationData]);
   // Set educations from the fetched data
	const handleDeleteEducation = (id) => {
		setEducations(educations.filter((edu) => edu._id !== id));
	};

	const handleSave = () => {
		onSave({ education: educations });
		setIsEditing(false);
	};
	const handleAddEducation = () => {
		saveEducationMutation.mutate({
		  institution: newEducation.institution,
		  field_of_study: newEducation.field_of_study,
		  start_year: parseInt(newEducation.start_year, 10),
      	  end_year: parseInt(newEducation.end_year, 10),
		  degree: newEducation.degree,
		});
		setNewEducation({
		  institution: "",
		  field_of_study: "",
		  start_year: "",
		  end_year: "",
		  degree: "",
		});
	  };
	return (
		<div className='bg-white shadow rounded-lg p-6 mb-6'>
			<h2 className='text-xl font-semibold mb-4'>Education</h2>
			{educations?.map((edu) => (
				<div key={edu.id} className='mb-4 flex justify-between items-start'>
					<div className='flex items-start'>
						<School size={20} className='mr-2 mt-1' />
						<div>
							<h3 className='font-semibold'>{edu.field_of_study}</h3>
							<p className='text-gray-600'>{edu.institution}</p>
							<p className='text-gray-500 text-sm'>
								{edu.start_year} - {edu.end_year || "Present"}
							</p>
						</div>
					</div>
					{isEditing && (
						<button onClick={() => handleDeleteEducation(edu.id)} className='text-red-500'>
							<X size={20} />
						</button>
					)}
				</div>
			))}
			{isEditing && (
				<div className="mt-4">
          <input
            type="text"
            placeholder="Institution"
            value={newEducation.institution}
            onChange={(e) =>
              setNewEducation({ ...newEducation, institution: e.target.value })
            }
            className="w-full p-2 border rounded mb-2"
          />
          <input
            type="text"
            placeholder="Field of Study"
            value={newEducation.field_of_study}
            onChange={(e) =>
              setNewEducation({
                ...newEducation,
                field_of_study: e.target.value,
              })
            }
            className="w-full p-2 border rounded mb-2"
          />
          <input
            type="number"
            placeholder="Start Year"
            value={newEducation.start_year}
            onChange={(e) =>
              setNewEducation({ ...newEducation, start_year: e.target.value })
            }
            className="w-full p-2 border rounded mb-2"
          />
          <input
            type="number"
            placeholder="End Year"
            value={newEducation.end_year}
            onChange={(e) =>
              setNewEducation({ ...newEducation, end_year: e.target.value })
            }
            className="w-full p-2 border rounded mb-2"
          />
          <input
            type="text"
            placeholder="Degree"
            value={newEducation.degree}
            onChange={(e) =>
              setNewEducation({ ...newEducation, degree: e.target.value })
            }
            className="w-full p-2 border rounded mb-2"
          />
					
					<button
						onClick={handleAddEducation}
						className='bg-primary text-white py-2 px-4 rounded hover:bg-primary-dark transition duration-300'
					>
						Add Education
					</button>
				</div>
			)}

			{isOwnProfile!=null && (
				<>
					{isEditing ? (
						<button
							// onClick={handleSave}
							className='mt-4 bg-primary text-white py-2 px-4 rounded hover:bg-primary-dark
							 transition duration-300'
						>
							Save Changes
						</button>
					) : (
						<button
							onClick={() => setIsEditing(true)}
							className='mt-4 text-primary hover:text-primary-dark transition duration-300'
						>
							Edit Education
						</button>
					)}
				</>
			)}
		</div>
	);
};
export default EducationSection;
