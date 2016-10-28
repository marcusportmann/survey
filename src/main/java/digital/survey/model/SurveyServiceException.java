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

package digital.survey.model;

/**
 * The <code>SurveyServiceException</code> exception is thrown to indicate an error
 * condition when working with the Service Service.
 * <p/>
 * NOTE: This is a checked exception to prevent the automatic rollback of the current transaction
 *       by the <code>TransactionalInterceptor</code>.
 *
 * @author Marcus Portmann
 */
public class SurveyServiceException extends Exception
{
  private static final long serialVersionUID = 1000000;

  /**
   * Constructs a new <code>SurveyServiceException</code> with <code>null</code> as its
   * message.
   */
  public SurveyServiceException()
  {
    super();
  }

  /**
   * Constructs a new <code>SurveyServiceException</code> with the specified message.
   *
   * @param message The message saved for later retrieval by the <code>getMessage()</code> method.
   */
  public SurveyServiceException(String message)
  {
    super(message);
  }

  /**
   * Constructs a new <code>SurveyServiceException</code> with the specified cause and a
   * message of <code>(cause==null ? null : cause.toString())</code> (which typically contains the
   * class and message of cause).
   *
   * @param cause The cause saved for later retrieval by the <code>getCause()</code> method.
   *              (A <code>null</code> value is permitted if the cause is nonexistent or unknown)
   */
  public SurveyServiceException(Throwable cause)
  {
    super(cause);
  }

  /**
   * Constructs a new <code>SurveyServiceException</code> with the specified message and
   * cause.
   *
   * @param message The message saved for later retrieval by the <code>getMessage()</code> method.
   * @param cause   The cause saved for later retrieval by the <code>getCause()</code> method.
   *                (A <code>null</code> value is permitted if the cause is nonexistent or unknown)
   */
  public SurveyServiceException(String message, Throwable cause)
  {
    super(message, cause);
  }
}
