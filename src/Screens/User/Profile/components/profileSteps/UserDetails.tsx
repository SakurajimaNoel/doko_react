import { View, Text, StyleSheet, Pressable, TextInput } from "react-native";
import React, { useState } from "react";
import { HandleSteps, UserDetailsProps } from "../../types";
import DatePicker from "react-native-date-picker";
import { Button } from "@rneui/base";

const UserDetails = ({
	handleNext,
	handlePrev,
	setUserInfo,
	userInfo,
}: UserDetailsProps) => {
	const [date, setDate] = useState(userInfo.dob);
	const [bio, setBio] = useState(userInfo.bio);
	const [open, setOpen] = useState<boolean>(false);

	const handlePress = () => {
		setOpen(true);
	};

	const handleSteps: HandleSteps = (prev = true) => {
		setUserInfo((prev) => ({ ...prev, dob: date, bio }));

		if (prev) handlePrev();
		else handleNext();
	};

	return (
		<View style={styles.container}>
			<Text style={styles.head}>User Details</Text>

			<View style={styles.detailContainer}>
				<Text style={styles.detailHead}>Date of Birth*</Text>

				<Pressable onPress={handlePress}>
					<Text style={styles.detailInput}>
						{date?.toDateString()}
					</Text>

					<DatePicker
						modal
						mode="date"
						open={open}
						date={date}
						onConfirm={(date) => {
							setOpen(false);
							setDate(date);
						}}
						onCancel={() => {
							setOpen(false);
						}}
					/>
				</Pressable>
			</View>

			<View style={styles.detailContainer}>
				<Text style={styles.detailHead}>Bio</Text>

				<TextInput
					style={styles.detailInput}
					multiline={true}
					numberOfLines={4}
					onChangeText={setBio}
					value={bio}
					placeholder="Bio here..."
					placeholderTextColor="#7F8487"
				/>
			</View>

			<View style={styles.buttonContainer}>
				<Button
					onPress={() => handleSteps()}
					title="Previous"
					type="outline"
					accessibilityLabel="Move to prevoius form step"
					containerStyle={{
						width: 100,
					}}
				/>

				<Button
					onPress={() => handleSteps(false)}
					title="Next"
					accessibilityLabel="Move to next page to fill details"
					containerStyle={{
						width: 90,
					}}
				/>
			</View>
		</View>
	);
};

const styles = StyleSheet.create({
	container: {
		padding: 10,
	},
	head: {
		color: "black",
		fontSize: 20,
		fontWeight: "500",
	},
	detailContainer: {
		padding: 10,
		marginBottom: 10,
	},
	detailHead: {
		color: "black",
		fontSize: 18,
		marginBottom: 10,
		fontWeight: "500",
	},
	detailInput: {
		borderWidth: 1,
		padding: 10,
		color: "#413F42",
		fontWeight: "500",
	},
	buttonContainer: {
		padding: 10,
		flexDirection: "row",
		justifyContent: "space-between",
	},
});

export default UserDetails;
