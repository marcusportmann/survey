/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package guru.mmp.survey.model;

//~--- JDK imports ------------------------------------------------------------

import javax.persistence.AttributeConverter;

/**
 * The <code>SurveyGroupRatingItemTypeConverter</code> class implements the custom JPA converter
 * for the <code>SurveyGroupRatingItemType</code> class.
 *
 * @author Marcus Portmann
 */
public class SurveyGroupRatingItemTypeConverter
  implements AttributeConverter<SurveyGroupRatingItemType, Integer>
{
  /**
   * Converts the value stored in the entity attribute into the data representation to be stored in
   * the database.
   *
   * @param attribute the entity attribute value to be converted
   *
   * @return the converted data to be stored in the database column
   */
  @Override
  public Integer convertToDatabaseColumn(SurveyGroupRatingItemType attribute)
  {
    return attribute.code();
  }

  /**
   * Converts the data stored in the database column into the value to be stored in the entity
   * attribute. Note that it is the responsibility of the converter writer to specify the correct
   * dbData type for the corresponding column for use by the JDBC driver: i.e., persistence
   * providers are not expected to do such type conversion.
   *
   * @param dbData the data from the database column to be converted
   *
   * @return the converted value to be stored in the entity attribute
   */
  @Override
  public SurveyGroupRatingItemType convertToEntityAttribute(Integer dbData)
  {
    return SurveyGroupRatingItemType.fromCode(dbData);
  }
}
