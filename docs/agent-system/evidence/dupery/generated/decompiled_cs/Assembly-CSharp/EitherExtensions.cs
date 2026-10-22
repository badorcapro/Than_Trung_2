public static class EitherExtensions
{
	public static Either<T1, T2> toEitherA<T1, T2>(this T1 _val)
	{
		return new Either<T1, T2>(_val);
	}

	public static Either<T1, T2> toEitherB<T1, T2>(this T2 _val)
	{
		return new Either<T1, T2>(_val);
	}
}
